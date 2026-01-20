
module server
module repo

main() {
  local pikuman_hosts

  while [ $# -gt 0 ]; do
    case "$1" in
      -*)
        case "$1" in
          -o|--output)
            echo "Handling $1 with value: $2"
            shift
            ;;
          *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        esac
        ;;
      *)
        break
        ;;
    esac
    shift
  done || true

  if [ -n "$PIKUMAN_HOSTS" ]; then
    pikuman_hosts=$PIKUMAN_HOSTS
  elif [ -f "$PWD/.hosts" ]; then
    pikuman_hosts="$PWD/.hosts"
  else
    pikuman_hosts="$HOME/.hosts"
  fi

  if [ "$#" -eq 0 ]; then
    echo "No arguments supplied" 1
  fi

  case "$1" in
    server:init)
      pikuman_server_init "$pikuman_hosts" "$2"
      ;;
    server:list)
      pikuman_server_list "$pikuman_hosts"
      ;;
    repo:init)
      pikuman_repo_init "$pikuman_hosts" "$2" "$3"
      ;;
    *)
      echo "Unknown command: $1" 1
      ;;
  esac
}
