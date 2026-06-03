if [ -d "${HOME}/.config/bash/rc.d" ]; then
  for i in $(run-parts --list --regex '^[a-zA-Z0-9_][a-zA-Z0-9._-]*\.sh$' "${HOME}/.config/bash/rc.d"); do
    if [ -r $i ]; then
      . $i
    fi
  done
  unset i
fi
