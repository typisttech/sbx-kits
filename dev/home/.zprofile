setopt nonomatch
for f in ~/.config/zprofile.d/*.zprofile; do
  [ -f "$f" ] && source "$f"
done
unsetopt nonomatch
