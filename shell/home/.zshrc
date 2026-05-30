if [[ -o interactive && ! -o login ]]; then
    [[ -f ~/.zprofile ]] && source ~/.zprofile
fi

setopt nonomatch
for f in ~/.config/zshrc.d/*.zshrc; do
  [ -f "$f" ] && source "$f"
done
setopt nomatch
