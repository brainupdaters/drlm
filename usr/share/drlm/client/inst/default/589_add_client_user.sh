# instclient workflow

# Create client users in DRLM server
if id "$CLI_NAME" &>/dev/null; then
  Log "Client user $CLI_NAME already exists"
else
  PASS=$(echo -n changeme | openssl passwd -1 -stdin)
  useradd -d /home/$CLI_NAME -c 'DRLM Client' -m -s /bin/bash -p $PASS $CLI_NAME &> /dev/null
  if [ $? -eq 0 ]; then 
    Log "Client user $CLI_NAME created"
  else 
    Error "Error creating client user $CLI_NAME"
  fi
fi 

# Disable client user login
chage -I -1 -m 0 -M 99999 -E -1 $CLI_NAME &> /dev/null
passwd -l $CLI_NAME &> /dev/null
if [ $? -eq 0 ]; then 
  Log "Clinet user logins disabled"
else 
  Error "Error disabling client user login"
fi

# Add authorized key from remote client to local client user
if [ "$PUBLIC_KEY" != "" ]; then
  # Create the .ssh directory
  if [ ! -d /home/$CLI_NAME/.ssh ]; then
    mkdir "/home/$CLI_NAME/.ssh" &> /dev/null 
    if [ $? -eq 0 ]; then Log ".ssh client user directory created"; else Error "Error creating .shh client user directory"; fi
  fi 

  # debian,ubuntu,centos and redhat permissions
  if getent group "$CLI_NAME" &> /dev/null; then
    chown $CLI_NAME:$CLI_NAME /home/$CLI_NAME/.ssh &> /dev/null
    if [ $? -eq 0 ]; then Log "Owership of .ssh client user directory changed"; else Error "Error changing ownership of .shh client user directory"; fi
  # openSUSE permisisons 
  elif getent group users &> /dev/null; then
    chown $CLI_NAME:users /home/$CLI_NAME/.ssh &> /dev/null
    if [ $? -eq 0 ]; then Log "Owership of .ssh client user directory changed"; else Error "Error changing ownership of .shh client user directory"; fi
  fi
  
  chmod 700 /home/$CLI_NAME/.ssh &> /dev/null
  if [ $? -eq 0 ]; then Log "Permissions of .ssh client user directory changed"; else Error "Error changing permissions of .shh client user directory"; fi

  # Add the authorized key
  echo "$PUBLIC_KEY" >> /home/$CLI_NAME/.ssh/authorized_keys
  if [ $? -eq 0 ]; then Log "Client public key added to .ssh/authorized_keys"; else Error "Client adding public key to .ssh/authorized_keys"; fi
  
  if getent group "$CLI_NAME" &> /dev/null; then
    chown $CLI_NAME:$CLI_NAME /home/$CLI_NAME/.ssh/authorized_keys &> /dev/null
    if [ $? -eq 0 ]; then Log "Owership of .ssh/authorized_keys client user file changed"; else Error "Error changing ownership of .ssh/authorized_keys client user file"; fi
  elif getent group users &> /dev/null; then
    chown $CLI_NAME:users /home/$CLI_NAME/.ssh/authorized_keys &> /dev/null
    if [ $? -eq 0 ]; then Log "Owership of .ssh/authorized_keys client user file changed"; else Error "Error changing ownership of .ssh/authorized_keys client user file"; fi
  fi

  chmod 600 /home/$CLI_NAME/.ssh/authorized_keys &> /dev/null
  if [ $? -eq 0 ]; then Log "Permissions of .ssh/authorized_keys client user file changed"; else Error "Error changing permissions of .ssh/authorized_keys client user file"; fi
fi