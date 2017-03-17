DRLM Certificate Generation
===========================

DRLM auto-generates cert files upon install with 1825 days (5 years) of expiration time.

If you need to re-generate the certificate or want to extend expiration time
please re-run the following command with proper options:

::

  openssl req -newkey rsa:4096 -nodes -keyout /etc/drlm/cert/drlm.key -x509 -days 1825 -subj "/C=ES/ST=CAT/L=GI/O=SA/CN=$(hostname -s)" -out /etc/drlm/cert/drlm.crt
