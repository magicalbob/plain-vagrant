{% for machine, args in pillar['host_machines'].iteritems() %}
{% if grains['localhost'] == args['host_name'] %}

build_hosts:
  file:
    - managed
    - name: /etc/hosts
    - source:   salt://hosts/templates/hosts.template
    - template: jinja

{% endif %}
{% endfor %}
