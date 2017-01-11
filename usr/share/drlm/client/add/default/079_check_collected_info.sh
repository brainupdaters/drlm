
if [ "$ADDCLI_MODE" == "online" ]; then

  printf '%-15s\n' "$(tput bold)"
  printf "The following information has been collected over network:"
  printf '%-15s\n' "$(tput bold)"
  printf '%-15s\n' "$(tput bold)"
  printf '%-15s %-15s %-15s %-15s\n' "Name" "MacAddres" "Ip" "Network$(tput sgr0)"
  printf '%-15s %-15s %-15s %-15s\n' "$CLI_NAME" "$CLI_MAC" "$CLI_IP" "$CLI_NET"
  printf '%-15s\n' "$(tput bold)"
  printf '%-15s' "Confirm? [y/N]: $(tput sgr0)"
  read -r RESPONSE
  case "$RESPONSE" in
    [yY][eE][sS]|[yY])
      shift ;;
    *)
      printf '\n' ""
      Print "If wrong/none information collected, set it manually."
      printf '\n' ""
      exit 1
      ;;
  esac

fi
