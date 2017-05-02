base:
  '*':
    - {{ grains['environment' ] }}_hosts
    - pass
