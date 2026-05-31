setopt nonomatch
for f in ~/.config/zshrc.d/*.zshrc; do
  [ -f "$f" ] && source "$f"
done
unsetopt nonomatch

# Source the sandbox persistent environment file
# https://docs.docker.com/ai/sandboxes/faq/#how-do-i-set-custom-environment-variables-inside-a-sandbox
if [ -f /etc/sandbox-persistent.sh ]; then
    source /etc/sandbox-persistent.sh
fi
