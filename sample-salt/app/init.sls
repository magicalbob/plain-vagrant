install_git:
  pkg.installed:
   - names:   
      - git
      - python2-pip

sample_app_git:
  git.latest:
   - name:   https://github.com/IBM-Bluemix/python-hello-world-flask.git
   - target: /opt/hello
   - require:
     - pkg:  install_git

sample_app_setup:
  cmd.run:
    - name:  pip install -r requirements.txt
    - cwd:   /opt/hello
    - require:
      - git:   sample_app_git

sample_app_service_conf:
  file.managed:
    - name:   /usr/lib/systemd/system/hello.service
    - source: salt://app/templates/hello.service
    - require:
      - cmd:   sample_app_setup

sample_app_service:
  service:
    - name:   hello
    - running
    - reload: True
    - enable: True
    - watch:
      - file:  sample_app_service_conf
    - require:
      - file:   sample_app_service_conf
