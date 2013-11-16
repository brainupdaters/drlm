# file with default client functions to implant.

function exist_client_id () {
  local CLI_ID=$1
# Check if parameter $1 is ok and if exists client with this id in database. Return 0 for ok, return 1 not ok.     
}

function exist_client_name(){
  local CLI_NAME=$1
# Check if parameter $1 is ok and if exists client with this name in database. Return 0 for ok, return 1 not ok.
}

function get_cient_id_by_name(){
  local CLI_NAME=$1
# Check if parameter $1 is ok
  if ( exist_client_name "$CLI_NAME" )
  then
# Get client id from database and return it
  else
# Error client not exist "exit X"?
  fi
}

function get_client_ip(){
  local CLI_ID=$1
# Check if parameter $1 is ok
  if ( exist_client_id "$CLI_ID" ) 
  then
# Get client ip from database and return it
  else
# Error client not exist "exit X"?
  fi
}

function get_client_name(){
  local CLI_ID=$1
# Check if parameter $1 is ok
  if ( exist_client_id "$CLI_ID" ) 
  then
# Get client name from database and return it
  else
# Error client not exist "exit X"?
  fi
}

function get_client_mac(){
  local CLI_ID=$1
# Check if parameter $1 is ok
  if ( exist_client_id "$CLI_ID" ) 
  then
# Get client mac from database and return it
  else
# Error client not exist "exit X"?
  fi
}

function check_client_connectivity(){
  local CLI_ID=$1
# Check if parameter $1 is ok
  if ( exist_client_id "$CLI_ID" ) 
  then
# Chek if client is available. Return 0 for ok, return 1 not ok.
  else
# Error client not exist "exit X"?
  fi
}
