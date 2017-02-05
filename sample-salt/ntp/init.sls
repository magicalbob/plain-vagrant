ntp_pkg:
  pkg.installed:
   - name: ntp

ntpd_service:
  service:
   - name: ntpd
   - running
   - enable: True
