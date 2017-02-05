nginx_pkg:
  pkg.installed:
   - names: 
     - nginx
     - policycoreutils-python

nginx_selinux_pp:
  file.managed:
   - name:   /var/tmp/nginx.pp
   - source: salt://nginx/selinux/nginx.pp

nginx_selinux_policy:
  cmd.run:
   - name: semodule -i /var/tmp/nginx.pp
   - require:
     - pkg:  nginx_pkg
     - file: nginx_selinux_pp

nginx_no_default:
  file.blockreplace:
   - name:         /etc/nginx/nginx.conf
   - marker_start: 'include /etc/nginx/conf.d/*.conf;'
   - marker_end:   '# Settings for a TLS enabled server.'
   - content:      ''
   - show_changes: True
   - require:
     - pkg:  nginx_pkg

nginx_clearout:
  cmd.run:
   - name: rm -f /etc/nginx/conf.d/*
   - require:
     - pkg: nginx_pkg

nginx_site:
  file.managed:
   - name:     /etc/nginx/conf.d/hello.conf
   - source:   salt://nginx/templates/site.template
   - template: jinja
   - require:
     - cmd: nginx_clearout
   

nginx_service:
  service:
    - name:   nginx
    - running
    - reload: True
    - enable: True
    - require:
      - file: nginx_site
      - file: nginx_no_default
      - cmd:  nginx_selinux_policy
