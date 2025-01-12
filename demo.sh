#!/bin/bash

# Setup

export CONTENT_BASE=./wiki
export CONFIG_BASE=./example-vale-config-files

shopt -s expand_aliases

if type bat > /dev/null 2>&1 ; then
  alias cat="$(type -p bat)"
  unset LESS
fi

if type open 2>&1 > /dev/null ; then
  alias xdg-open=$(type -p open)
fi


if [ ! -f demo-magic.sh ] ; then 
  echo Downloaing demo-magic from https:/sample/github.com/paxtonhare/demo-magic
  curl https://raw.githubusercontent.com/paxtonhare/demo-magic/master/demo-magic.sh -o demo-magic.sh
fi

rm -r .styles/ .vale.ini

source ./demo-magic.sh
clear

echo Are we set for success?
echo

pe "vale --version"

pe "xdg-open https://vale.sh/"

wezterm imgcat wiki-qr.png --width 40 --height 40

pe "tree $CONTENT_BASE $CONFIG_BASE"

# Start Simple

pe "cat $CONTENT_BASE/Home.md"

pe "cat $CONFIG_BASE/example0.ini"

pe "xdg-open 'https://vale.sh/docs/styles#vale'"

pe "vale --config $CONFIG_BASE/example0.ini $CONTENT_BASE/Home.md"
pe "VALE_CONFIG_PATH=$CONFIG_BASE/example0.ini vale $CONTENT_BASE/Home.md"

pe "cp $CONFIG_BASE/example0.ini .vale.ini"
pe "vale --no-wrap $CONTENT_BASE/Home.md"
echo Much more useful, lint a whole directory tree
pe "vale --no-wrap $CONTENT_BASE"

pe "vale ls-config"

pe "vale ls-metrics $CONTENT_BASE/Home.md"
pe "vale ls-metrics $CONTENT_BASE/Home.md | jq .words"
pe "wc -w $CONTENT_BASE/Home.md"

pe "cp $CONFIG_BASE/example1.ini .vale.ini"

pe "cat .vale.ini"

pe "xdg-open 'https://github.com/errata-ai/packages?tab=readme-ov-file#available-styles'"

# pe "mkdir -p .styles/"

pe "tree .styles"

pe "vale sync"

pe "tree .styles"

pe "cat .styles/Google/OxfordComma.yml"

pe "vale --no-wrap $CONTENT_BASE/Home.md"

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

# Change alert level

pe "cp $CONFIG_BASE/example2.ini .vale.ini"

pe "cat .vale.ini"

pe "vale sync"

pe "ls .styles"

pe "vale --no-wrap $CONTENT_BASE/Home.md"

# Add project Vocab

pe "cp $CONFIG_BASE/example3.ini .vale.ini"

pe "cat .vale.ini"

pe "mkdir -p .styles/config/vocabularies/ProjectVocab/"

pe "echo 'repos?' >> .styles/config/vocabularies/ProjectVocab/accept.txt"

pe "vale --no-wrap $CONTENT_BASE/Home.md"

# Create our own spelling rules for AU English

pe "curl --output '.styles/config/dictionaries/en_AU.#1' --create-dirs \
  'https://raw.githubusercontent.com/LibreOffice/dictionaries/master/en/en_AU.{dic,aff}'"

pe "tree .styles/config/dictionaries

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

pe "cp $CONFIG_BASE/example4.ini .vale.ini"

pe "cat .vale.ini"

pe "vale --no-wrap $CONTENT_BASE/Home.md"

