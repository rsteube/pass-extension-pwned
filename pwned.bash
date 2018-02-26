#!/usr/bin/env bash
location="${PASSWORD_STORE_DIR:-$HOME/.password-store}"
entries=$(find -L "$location" -name *.gpg 2>/dev/null | sed -e "s#$location/##" -e 's/\.gpg//')

for entry in $entries; do
  sha1="$(pass show $entry | tr -d '\n' | sha1sum)"
  prefix=${sha1:0:5}
  suffix=${sha1:5:-3}
  
  echo -n "$entry "
  
  pwnedlist="$(curl -A 'github.com/rsteube/pass-extension-pwned' -s https://api.pwnedpasswords.com/range/$prefix)"
  [ $? -ne 0 ] && echo -e '[\e[33mFAILED TO CONTACT SERVICE\e[39m]' && continue

  echo "$pwnedlist" | grep -i "${suffix}\:[0-9]\+" >/dev/null && echo -e '[\e[31mPWNED\e[39m]' || echo -e '[\e[32mOK\e[39m]'
done



