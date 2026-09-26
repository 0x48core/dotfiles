# Load Rust/Cargo environment if available
if [ -f "$HOME/.cargo/env" ]; then
  source "$HOME/.cargo/env"
fi

# rtk: ensure ~/.local/bin on PATH
export RTK_TELEMETRY_DISABLED=1
case ":${PATH}:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:${PATH}" ;;
esac
