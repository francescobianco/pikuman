
module server

pikuman_repo_init() {
  local hosts
  local piku_server
  local piku_app
  local variables
  local host

  hosts="$1"
  piku_server="$2"
  piku_app="$3"

  variables=$(pikuman_server_vars "${hosts}" "${piku_server}")

  if [ -z "${variables}" ]; then
    echo "Error: Server '${piku_server}' not found in hosts file '${hosts}'" 1
    return 1
  fi

  echo "Initializing repository: $PWD for app '${piku_app}' on server '${piku_server}' using hosts file '${hosts}'"

  for variable in $variables; do
    declare "$variable"
  done

  git remote remove piku >/dev/null 2>&1 || true
  git remote add piku "piku@${host}:${piku_app}"
}
