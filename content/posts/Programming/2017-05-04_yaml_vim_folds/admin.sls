aws:
  post_bootstrap: {{ POST_BOOTSTRAP }}
  vpcs:
    {{ BOOTSTRAP_CONF.name }}:
      cidr_block: {{ BOOTSTRAP_CONF.cidr_block }}

      secgroups:
        test_self:
          description: WARNING, use only for testing.  Lets all TEST-SELF servers talk freely amongst eachother.
          rules:
            - ip_protocol: all
              from_port: -1
              to_port: -1
              source_group_name: {{ BOOTSTRAP_CONF.sec_groups.test_self.name }}
          rules_egress:
            - ip_protocol: all
              from_port: -1
              to_port: -1
              source_group_name: {{ BOOTSTRAP_CONF.sec_groups.test_self.name }}

        salt_master:
          description: Salt master server rules
          rules:
            - ip_protocol: tcp
              from_port: 4505
              to_port: 4506
              source_group_name: {{ BOOTSTRAP_CONF.sec_groups.managed.name }}
            {% if POST_BOOTSTRAP %}
            - ip_protocol: tcp
              from_port: 4505
              to_port: 4506
              source_group_group_id: {{ DEV_MANAGED_GROUP_ID }}
            {% endif %}
          rules_egress:
            - ip_protocol: tcp
              from_port: 22
              to_port: 22
              cidr_ip:
                - 0.0.0.0/0
