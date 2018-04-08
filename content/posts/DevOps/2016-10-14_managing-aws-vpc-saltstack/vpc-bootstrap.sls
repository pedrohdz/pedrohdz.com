{% set profile = {
    'keyid': 'AKIAI6KSXB7BE3SPQ3WQ',
    'key': 'Zm4v1bsYiVX+ROPH4ZsI8qi9O0ZmxSvYaJdO5FgN',
    'region': 'us-west-2'
    }
%}
{% set public_ssh_key = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCaDFmnspSfuS87D5FOTIrucK9byDzOhYVFnAxMmACatEllM+v2ZsLH9AfoDDHkEygD1uSgbC4HwZzJOFvkDePo5BQQS2VR4aJv4vyufG3aMLxDD4CgXXbgQBai/T2P82hNTZHbLMljQQuEAfrGBM67a2OKo1ssbE7E3B5D8yUM469OSUKtUSf6wh3JkGPLYD+t3xdJERDJe9ow2liV0FjWk2u6TDCDXsdcFfUOyIbBoIhf5W2HpXHcgqFnNVDUWQ1TJjtDqEbzvXIUzEQoGBbSm36FbOZMMtl6xQJFZzRPYa/xdh1w+8sKOPfGtD1+ItX6NLjHUn1cGDHmTth7hWkj DEMO-TEMP' %}
{% set ec2_image_id = 'ami-f1ca1091' %}
{% set vpc_name = 'DEMO-SALTSTACK-VPC' %}
{% set vpc_short_name = 'DEMO' %}
{% set vpc_cidr_block = '10.102.192.0/21' %}
{% set vpc_domain_name = 'demo-saltstack-vpc.local' %}
{% set subnet0 = '10.102.192.0/24' %}
{% set subnet1 = '10.102.193.0/24' %}


# -----------------------------------------------------------------------------
# Does not need the VPC to exist
# -----------------------------------------------------------------------------
# Create IAM role first to avoid race condition.
SaltStack master IAM role exists:
  boto_iam_role.present:
    - name: {{ vpc_short_name ~ '-SALTSTACK-MASTER' }}
    - create_instance_profile: True
    - path: /
    - policies:
        {{ vpc_short_name ~ '-SALTSTACK-MASTER' }}:
          Statement:
            - Action: '*'
              Effect: Allow
              Resource: '*'
    - profile: {{ profile }}

EC2 demo key pair exists:
  boto_ec2.key_present:
    - name: {{ vpc_short_name ~ '-PUBLIC_KEY' }}
    - upload_public: {{ public_ssh_key }}
    - profile: {{ profile }}


# -----------------------------------------------------------------------------
# VPC (boto_vpc)
# -----------------------------------------------------------------------------
Demo VPC exists:
  boto_vpc.present:
    - name: {{ vpc_name }}
    - cidr_block: {{ vpc_cidr_block }}
    - dns_support: True
    - dns_hostnames: True
    - profile: {{ profile }}

Internet gateway exists:
  boto_vpc.internet_gateway_present:
    - name: {{ vpc_name }}
    - vpc_name: {{ vpc_name }}
    - profile: {{ profile }}

DHCP options exists:
  boto_vpc.dhcp_options_present:
    - name: {{ vpc_name }}
    - vpc_name: {{ vpc_name }}
    - domain_name: {{ vpc_domain_name }}
    - domain_name_servers:
      - AmazonProvidedDNS
    - profile: {{ profile }}

# Make sure to add logic to spread across availability zones.
Subnet subnet0 exists:
  boto_vpc.subnet_present:
    - name: {{ vpc_name ~ '-subnet0' }}
    - cidr_block: {{ subnet0 }}
    - vpc_name: {{ vpc_name }}
    - profile: {{ profile }}

Subnet subnet1 exists:
  boto_vpc.subnet_present:
    - name: {{ vpc_name ~ '-subnet1' }}
    - cidr_block: {{ subnet1 }}
    - vpc_name: {{ vpc_name }}
    - profile: {{ profile }}

# This creates a second routing table.  Make sure to set as default.
Routing table exists:
  boto_vpc.route_table_present:
    - name: {{ vpc_name }}
    - vpc_name: {{ vpc_name }}
    - routes:
      - destination_cidr_block: 0.0.0.0/0
        internet_gateway_name: {{ vpc_name }}
    - subnet_names:
      - {{ vpc_name ~ '-subnet0' }}
      - {{ vpc_name ~ '-subnet1' }}
    - profile: {{ profile }}


# -----------------------------------------------------------------------------
# Security groups (boto_secgroup)
# -----------------------------------------------------------------------------
Bastion security group exists:
  boto_secgroup.present:
    - name: {{ vpc_short_name ~ '+BASTION' }}
    - description: SSH bastion server rules
    - vpc_name: {{ vpc_name }}
    - rules:
      - ip_protocol: tcp
        from_port: 22
        to_port: 22
        cidr_ip:
          - 0.0.0.0/0
    - rules_egress:
      - ip_protocol: tcp
        from_port: 22
        to_port: 22
        cidr_ip:
          - {{ vpc_cidr_block }}
    - profile: {{ profile }}

Bastioned server security group exists:
  boto_secgroup.present:
    - name: {{ vpc_short_name ~ '+BASTIONED-SERVER' }}
    - description: Only allow SSH access from the bastion
    - vpc_name: {{ vpc_name }}
    - rules:
      - ip_protocol: tcp
        from_port: 22
        to_port: 22
        source_group_name: {{ vpc_short_name ~ '+BASTION' }}
    - rules_egress: []
    - profile: {{ profile }}

# Chicken and the egg.
SaltStack master security group exists:
  boto_secgroup.present:
    - name: {{ vpc_short_name ~ '+SALTSTACK-MASTER' }}
    - description: SaltStack master rules
    - vpc_name: {{ vpc_name }}
    - profile: {{ profile }}

SaltStack minion security group exists:
  boto_secgroup.present:
    - name: {{ vpc_short_name ~ '+SALTSTACK-MINION' }}
    - description: SaltStack minion rules
    - vpc_name: {{ vpc_name }}
    - profile: {{ profile }}

SaltStack master security group configured:
  boto_secgroup.present:
    - name: {{ vpc_short_name ~ '+SALTSTACK-MASTER' }}
    - description: SaltStack master rules
    - vpc_name: {{ vpc_name }}
    - rules:
      - ip_protocol: tcp
        from_port: 4505
        to_port: 4506
        source_group_name: {{ vpc_short_name ~ '+SALTSTACK-MINION' }}
    - rules_egress: []
    - profile: {{ profile }}

SaltStack minion security group configured:
  boto_secgroup.present:
    - name: {{ vpc_short_name ~ '+SALTSTACK-MINION' }}
    - description: SaltStack minion rules
    - vpc_name: {{ vpc_name }}
    - rules: []
    - rules_egress:
      - ip_protocol: tcp
        from_port: 4505
        to_port: 4506
        source_group_name: {{ vpc_short_name ~ '+SALTSTACK-MASTER' }}
    - profile: {{ profile }}


# -----------------------------------------------------------------------------
# EC2 Instance - Very last thing to make sure everything else was done.
# -----------------------------------------------------------------------------
EC2 demo server exists:
  boto_ec2.instance_present:
    - name: {{ 'demo00.' ~ vpc_domain_name }}
    - vpc_name: {{ vpc_name }}
    - image_id: {{ ec2_image_id }}
    - instance_type: t2.nano
    - key: demo-admin-ssh-key
    - instance_profile_name: {{ vpc_short_name ~ '-SALTSTACK-MASTER' }}
    - subnet_name: {{ vpc_name ~ '-subnet1' }}
    - profile: {{ profile }}
    - user_data: |
        #cloud-config
        apt_sources:
         - source: deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/2016.3 xenial main
           keyid: DE57BFBE
           filename: saltstack-201603.list
        packages:
          - python-boto
          - salt-minion
          - rng-tools

# vim: filetype=sls tabstop=2 shiftwidth=2 expandtab
