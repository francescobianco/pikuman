
pikuman_server_init() {
  local hosts
  local piku_server
  local variables
  local user
  local host
  local password
  local public_key

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

  public_key=$(cat "${HOME}/.ssh/id_rsa.pub")

  ssh-keygen -f "${HOME}/.ssh/known_hosts" -R "${host}"

  sshpass -p "${password}" ssh -o StrictHostKeyChecking=accept-new "${user}@${host}" << EOF
export LC_ALL="C.UTF-8"
rm -fr .piku-bootstrap piku-bootstrap
echo "Downloading piku-bootstrap here."
curl -s https://raw.githubusercontent.com/francescobianco/piku-bootstrap/master/piku-bootstrap > piku-bootstrap
chmod 755 piku-bootstrap
./piku-bootstrap install
rm -fr .piku-bootstrap piku-bootstrap
echo "${public_key}" > /tmp/piku.pub
sudo -u piku /usr/bin/python3 /home/piku/piku.py setup:ssh /tmp/piku.pub
EOF
}

pikuman_server_vars() {
  local hosts
  local select_piku_server
  local piku_server

  hosts="$1"
  select_piku_server="$2"

  if [ -z "${select_piku_server}" ]; then
    echo "Error: No piku_server specified" 1
    return 1
  fi

  while read -r variables; do
    [ -z "${variables}" ] && continue
    [ "${variables:0:2}" == "##" ] && echo "====[ ${variables:3} ]===="
    [ "${variables:0:5}" != "host=" ] && continue

    for variable in $variables; do
      declare "$variable";
    done

    if [ "${piku_server}" = "${select_piku_server}" ]; then
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
    declare "piku_server="
    for variable in $variables; do
      declare "$variable"
    done
    if [ -n "${piku_server}" ]; then
      echo "${piku_server} (${host})"
    fi
  done < "${hosts}"
}
