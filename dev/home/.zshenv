setopt nonomatch
for f in ~/.config/zshenv.d/*.zshenv; do
  [ -f "$f" ] && source "$f"
done
unsetopt nonomatch
