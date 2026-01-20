
pikuman_server_init() {
  local hosts
  local piku_server
  local variables
  local user
  local host
  local password

  hosts="$1"
  piku_server="$2"
  variables=$(pikuman_server_vars "${hosts}" "${piku_server}")

  if [ -z "${variables}" ]; then
    echo "Error: Server '${piku_server}' not found in hosts file '${hosts}'" 1
    return 1
  fi

  echo "Initializing server '${piku_server}' in hosts file '${hosts}'"

  for variable in $variables; do
    declare "$variable"
  done

  [ -z "${user}" ] && user=$USER

  ssh-keygen -f "${HOME}/.ssh/known_hosts" -R "${host}"

  sshpass -p "${password}" ssh -o StrictHostKeyChecking=accept-new "${user}@${host}" << EOF
curl https://piku.github.io/get | sh
./piku-bootstrap first-run --no-interactive
EOF
}

pikuman_server_vars() {
  local hosts
  local select_piku_server

  hosts="$1"
  select_piku_server="$2"

  while read -r variables; do
    [ -z "${variables}" ] && continue
    [ "${variables:0:2}" == "##" ] && echo "====[ ${variables:3} ]===="
    [ "${variables:0:5}" != "host=" ] && continue
    for variable in $variables; do declare "$variable"; done

    if [ "${piku_server}" == "${select_piku_server}" ]; then
      echo "$variables"
      return 0
    fi
  done < "${hosts}"
}

pikuman_server_list() {
  local hosts
  local variables
  local piku_server
  local host

  hosts=$1
  #echo "Hosts:${hosts}"
  while read -r variables; do
    [ -z "${variables}" ] && continue
    [ "${variables:0:2}" == "##" ] && echo "====[ ${variables:3} ]===="
    [ "${variables:0:5}" != "host=" ] && continue
    for variable in $variables; do
      declare "$variable"
    done
    echo "${piku_server} (${host})"
  done < "${hosts}"
}
