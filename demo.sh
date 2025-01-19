#!/bin/bash

# Setup

export CONTENT_BASE=./wiki
export CONFIG_BASE=./example-vale-config-files

shopt -s expand_aliases

if type bat > /dev/null 2>&1 ; then
  alias cat="$(type -p bat)"  # Bat is a fancy cat
  unset LESS # Don't want less getting confused
fi

if type open 2>&1 > /dev/null ; then
  alias xdg-open=$(type -p open)  # On a Mac probably
fi

if type gsed 2>&1 > /dev/null ; then
  echo Need GNU sed installed as gsed
  return 1
fi


if [ ! -f demo-magic.sh ] ; then 
  echo Downloaing demo-magic from https:/sample/github.com/paxtonhare/demo-magic
  curl https://raw.githubusercontent.com/paxtonhare/demo-magic/master/demo-magic.sh -o demo-magic.sh
fi

# Initialise from last run
rm -r .styles/ .vale.ini

source ./demo-magic.sh
clear
p "Let's lern about Vale"
echo "Are we set for success?"

pe "vale --version"

pe "xdg-open https://vale.sh/"

echo "Workshop resources at https://github.com/alecthegeek/vale-tutorial"
wezterm imgcat repo-qr.png --width 40 --height 40

pe "xdg-open https://github.com/alecthegeek/vale-tutorial"

pe "tree $CONTENT_BASE $CONFIG_BASE"

pe "cat $CONTENT_BASE/Home.md"
pe "cat $CONTENT_BASE/02-First-Steps.md"

p "Start Simple"

pe "cat $CONFIG_BASE/example0.ini"

pe "xdg-open 'https://vale.sh/docs/styles#vale'"

pe "cp $CONFIG_BASE/example0.ini .vale.ini"
pe "cat .vale.ini"
pe "vale $CONTENT_BASE/Home.md"
pe "vale --no-wrap $CONTENT_BASE/Home.md"

p "Much more useful, lint a whole directory tree"
pe "vale --no-wrap $CONTENT_BASE"

p "Vale Handy Tip -- Counting words"
pe "vale ls-metrics $CONTENT_BASE/Home.md"
pe "vale ls-metrics $CONTENT_BASE/Home.md | jq .words"
pe "wc -w $CONTENT_BASE/Home.md"

pe "vale ls-metrics $CONTENT_BASE/02-First-Steps.md | jq .words"
pe "wc -w $CONTENT_BASE/02-First-Steps.md"

p "Let's Install some packages"

pe "cp $CONFIG_BASE/example1.ini .vale.ini"

pe "cat .vale.ini"


pe "xdg-open 'https://github.com/errata-ai/packages?tab=readme-ov-file#available-styles'"

pe "ls .style"

pe "vale sync"

pe "tree .styles"

pe "cat .styles/Google/OxfordComma.yml"

pe "vale --no-wrap $CONTENT_BASE/Home.md"

pe "vale ls-config"

pe "vale --no-global ls-config"

p "Ignore suggestions, only display errors and warnings"

gsed -i -e '1 i\
; Set Reporting Level. Ignore suggestions\
MinAlertLevel = warning\
' .vale.ini

pe "cat .vale.ini"

pe "vale wiki/Home.md"

echo >> .vale.ini
echo "Google.OxfordComma = error" >> .vale.ini

pe "cat .vale.ini"

pe "vale --no-wrap $CONTENT_BASE/Home.md"

cp $CONFIG_BASE/example1.ini .vale.ini
echo >> .vale.ini
echo "Google.OxfordComma = NO" >> .vale.ini

pe "cat .vale.ini"

pe "vale --no-wrap $CONTENT_BASE/Home.md"

cp $CONFIG_BASE/example1.ini .vale.ini
echo >> .vale.ini
echo "Google.OxfordComma = suggestion" >> .vale.ini

pe "cat .vale.ini"

pe "vale --no-wrap $CONTENT_BASE/Home.md"

pe "xdg-open https://github.com/canonical/praecepta/blob/main/vale.ini"

p "Add Another Package"

pe "cp $CONFIG_BASE/example2.ini .vale.ini"

pe "cat .vale.ini"

pe "vale sync"

pe "ls .styles"

pe "vale --no-wrap $CONTENT_BASE/Home.md"

p "Add project Vocab"

# pe "cp $CONFIG_BASE/example3.ini .vale.ini"

pe "cat .vale.ini"

pe "mkdir -p .styles/config/vocabularies/ProjectVocab/"

printf 'Plantuml\nrepos?' >> .styles/config/vocabularies/ProjectVocab/accept.txt

pe "cat .styles/config/vocabularies/ProjectVocab/accept.txt"

pe "vale --no-wrap $CONTENT_BASE/Home.md"

p "Create our own spelling rules for AU English"

pe "vale --ext=.md 'Flavour Flavor Flavar'"

p "We Need a 'Strayan dictionary"

pe "xdg-open https://github.com/LibreOffice/dictionaries/"

pe "curl --output '.styles/config/dictionaries/en_AU.#1' --create-dirs \
  'https://raw.githubusercontent.com/LibreOffice/dictionaries/master/en/en_AU.{dic,aff}'"

pe "tree .styles/config/dictionaries"

pe "mkdir .styles/ProjectStyle"

cat > .styles/ProjectStyle/Spelling_AU.yml <<EOF
extends: spelling
level: error
message: "'%s' is not AU English"
dicpath: .styles/config/dictionaries
dictionaries:
  - en_AU
EOF

cat .styles/ProjectStyle/Spelling_AU.yml 

# pe "cp $CONFIG_BASE/example4.ini .vale.ini"

pe "cat .vale.ini"

pe "vale --no-wrap $CONTENT_BASE/Home.md"

p "Fine Grained Spell Checking"
p "Download a US dictionary"

pe "curl --output '.styles/config/dictionaries/en_US.#1' --create-dirs \
  'https://raw.githubusercontent.com/LibreOffice/dictionaries/master/en/en_US.{dic,aff}'"

cat > .styles/ProjectStyle/Spelling_US.yml <<EOF
extends: spelling
level: error
message: "'%s' is not US English"
dicpath: .styles/config/dictionaries
dictionaries:
  - en_US
EOF

cat .styles/ProjectStyle/Spelling_US.yml 

pe "cp $CONFIG_BASE/example5.ini .vale.ini"

pe "cat .vale.ini"

pe "vale --ext=.md 'Flavour Flavor'"

cat <<EOF > /tmp/sampleUSspelling.md

<!--
ProjectStyle.Spelling_AU = NO
ProjectStyle.Spelling_US = YES
-->

* Facebook Privacy Center:  https://www.facebook.com/privacy/center/

<!--
ProjectStyle.Spelling_AU = YES
ProjectStyle.Spelling_US = NO
-->


EOF

pe "cat /tmp/sampleUSspelling.md | vale -ext=.md

p "Let\'s do something fancy"

p "Make Vale check a fenced code block, (```mermaid ... ```)"

p "cat wiki/02-First-Steps.md"

p "gsed -ne '/```mermaid/,/```/{/```mermaid/!{/```/!p}}'  wiki/02-First-Steps.md"

p "gsed -ne '/```mermaid/,/```/{/```mermaid/!{/```/!p}}'  wiki/02-First-Steps.md | vale -ext=.md"


