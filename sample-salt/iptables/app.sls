{# 
  =================================================
  Set up base firewall rule for hello world
  ================================================= 
#}

app_rule:
  iptables.append:
    - table:     filter
    - chain:     INPUT
    - jump:      ACCEPT
    - match:     state
    - connstate: NEW
    - dport:     8080 
    - proto:     tcp
    - save:      True

