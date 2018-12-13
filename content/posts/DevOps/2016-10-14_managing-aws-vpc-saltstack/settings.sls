{% set profile = {
    'keyid': salt['environ.get']('AWS_KEY_ID'),
    'key': salt['environ.get']('AWS_ACCESS_KEY'),
    'region': salt['environ.get']('AWS_REGION')
    }
%}
{% set vpc_name = 'DEMO-SALTSTACK-VPC' %}
{% set vpc_cidr_block = '10.102.192.0/21' %}
{% set vpc_domain_name = 'demo-saltstack-vpc' %}
