
{# 
  =================================================
  Set up base firewall rules used on every machine
  ================================================= 
#}

clear-out:
  iptables.flush:
    - table:     filter
    - save:      True

input-policy:
    iptables.set_policy:
    - table: filter
    - policy: DROP 
    - chain: INPUT

for-est:
  iptables.append:
    - table:     filter
    - chain:     INPUT
    - jump:      ACCEPT
    - match:     state
    - connstate: ESTABLISHED,RELATED
    - save:      True
      
snmp-rule:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - match: state
    - connstate: NEW
    - dport: 161 
    - proto: udp
    - save: True

ssh-rule:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - match: state
    - connstate: NEW
    - dport: 22 
    - proto: tcp
    - save: True

{% if grains['role'] == 'admin' %}
{# 
  =================================================
  Set up firewall rule for admin
  ================================================= 
#}

salt-rule-1:
  iptables.append:
    - table:     filter
    - chain:     INPUT
    - jump:      ACCEPT
    - match:     state
    - connstate: NEW
    - dport:     4505
    - proto:     tcp
    - save:      True

salt-rule-2:
  iptables.append:
    - table:     filter
    - chain:     INPUT
    - jump:      ACCEPT
    - match:     state
    - connstate: NEW
    - dport:     4506
    - proto:     tcp
    - save:      True
{% endif %}
