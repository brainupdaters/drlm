DRLM Certificate Generation
===========================

DRLM auto-generates cert files with ECC-521 cipher on install with 1825 days (5 years) of expiration time.

If you need to re-generate the certificate or want to extend expiration time
please re-run the following command with proper options:

::

  openssl ecparam -name secp521r1 -genkey -out /etc/drlm/cert/drlm.key
  openssl req -new -x509 -key /etc/drlm/cert/drlm.key -out /etc/drlm/cert/drlm.crt -days 1825 -subj "/C=ES/ST=CAT/L=GI/O=SA/CN=$(hostname -s)"

For very old distros the default certificate ciphers do not work, you can recreate them with RSA-4096 reducing the security of the transport at 
your own risk. You may want to dedicate a DRLM server instance for older distros so tyhe security is not compromised to the rest of the clients.

::

  openssl req -newkey rsa:4096 -nodes -keyout /etc/drlm/cert/drlm.key -x509 -days 1825 -subj "/C=ES/ST=CAT/L=GI/O=SA/CN=$(hostname -s)" -out /etc/drlm/cert/drlm.crt
