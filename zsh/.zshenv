. "$HOME/.cargo/env"

# rtk: ensure ~/.local/bin on PATH
export RTK_TELEMETRY_DISABLED=1
case ":${PATH}:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:${PATH}" ;;
esac
