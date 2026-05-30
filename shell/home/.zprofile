# Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"

setopt nonomatch
for f in ~/.config/zprofile.d/*.zprofile; do
  [ -f "$f" ] && source "$f"
done
setopt nomatch

# Homebrew
# https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh
autoload -Uz compinit
compinit

# Source the sandbox persistent environment file
# https://docs.docker.com/ai/sandboxes/faq/#how-do-i-set-custom-environment-variables-inside-a-sandbox
if [ -f /etc/sandbox-persistent.sh ]; then
    source /etc/sandbox-persistent.sh
fi
