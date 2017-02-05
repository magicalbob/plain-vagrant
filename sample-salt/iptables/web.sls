{# 
  =================================================
  Set up base firewall rule for http
  ================================================= 
#}

http_rule:
  iptables.append:
    - table:     filter
    - chain:     INPUT
    - jump:      ACCEPT
    - match:     state
    - connstate: NEW
    - dport:     80
    - proto:     tcp
    - save:      True

