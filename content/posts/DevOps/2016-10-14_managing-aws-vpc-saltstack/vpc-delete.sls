{% set profile = {
    'keyid': 'AKIAI6KSXB7BE3SPQ3WQ',
    'key': 'Zm4v1bsYiVX+ROPH4ZsI8qi9O0ZmxSvYaJdO5FgN',
    'region': 'us-west-2'
    }
%}
{% set vpc_name = 'DEMO-SALTSTACK-VPC' %}
{% set vpc_short_name = 'DEMO' %}
{% set vpc_domain_name = 'demo-saltstack-vpc.local' %}

EC2 demo server absent:
  boto_ec2.instance_absent:
    - name: {{ 'demo00.' ~ vpc_domain_name }}
    - profile: {{ profile }}

SaltStack master IAM role absent:
  boto_iam_role.absent:
    - name: {{ vpc_short_name ~ '-SALTSTACK-MASTER' }}
    - profile: {{ profile }}

EC2 demo key pair absent:
  boto_ec2.key_absent:
    - name: {{ vpc_short_name ~ '-PUBLIC_KEY' }}
    - profile: {{ profile }}


# -----------------------------------------------------------------------------
Bastion security group empty:
  boto_secgroup.present:
    - name: {{ vpc_short_name ~ '+BASTION' }}
    - description: DELETE
    - vpc_name: {{ vpc_name }}
    - rules: []
    - rules_egress: []
    - profile: {{ profile }}

Bastioned server security group empty:
  boto_secgroup.present:
    - name: {{ vpc_short_name ~ '+BASTIONED-SERVER' }}
    - description: DELETE
    - vpc_name: {{ vpc_name }}
    - rules: []
    - rules_egress: []
    - profile: {{ profile }}

SaltStack master security group empty:
  boto_secgroup.present:
    - name: {{ vpc_short_name ~ '+SALTSTACK-MASTER' }}
    - description: DELETE
    - vpc_name: {{ vpc_name }}
    - rules: []
    - rules_egress: []
    - profile: {{ profile }}

SaltStack minion security group empty:
  boto_secgroup.present:
    - name: {{ vpc_short_name ~ '+SALTSTACK-MINION' }}
    - description: DELETE
    - vpc_name: {{ vpc_name }}
    - rules: []
    - rules_egress: []
    - profile: {{ profile }}

Bastion security group absent:
  boto_secgroup.absent:
    - name: {{ vpc_short_name ~ '+BASTION' }}
    - vpc_name: {{ vpc_name }}
    - profile: {{ profile }}

Bastioned server security group absent:
  boto_secgroup.absent:
    - name: {{ vpc_short_name ~ '+BASTIONED-SERVER' }}
    - vpc_name: {{ vpc_name }}
    - profile: {{ profile }}

SaltStack master security group absent:
  boto_secgroup.absent:
    - name: {{ vpc_short_name ~ '+SALTSTACK-MASTER' }}
    - vpc_name: {{ vpc_name }}
    - profile: {{ profile }}

SaltStack minion security group absent:
  boto_secgroup.absent:
    - name: {{ vpc_short_name ~ '+SALTSTACK-MINION' }}
    - vpc_name: {{ vpc_name }}
    - profile: {{ profile }}
# -----------------------------------------------------------------------------

Wait for instance to terminate (HACK):
  module.run:
    - name: test.sleep
    - length: 90

Subnet subnet0 absent:
  boto_vpc.subnet_absent:
    - name: {{ vpc_name ~ '-subnet0' }}
    - profile: {{ profile }}

Subnet subnet1 absent:
  boto_vpc.subnet_absent:
    - name: {{ vpc_name ~ '-subnet1' }}
    - profile: {{ profile }}

Routing table absent:
  boto_vpc.route_table_absent:
    - name: {{ vpc_name }}
    - profile: {{ profile }}

Internet gateway absent:
  boto_vpc.internet_gateway_absent:
    - name: {{ vpc_name }}
    - detach: True
    - profile: {{ profile }}

Demo VPC absent:
  boto_vpc.absent:
    - name: {{ vpc_name }}
    - profile: {{ profile }}

DHCP options absent:
  boto_vpc.dhcp_options_absent:
    - name: {{ vpc_name }}
    - profile: {{ profile }}

# vim: filetype=sls tabstop=2 shiftwidth=2 expandtab
