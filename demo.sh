#!/bin/bash

# Setup

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

rm -r .styles/

source ./demo-magic.sh

clear

pe "tree"

# Start Simple

pe "cp example-vale-config-files/example0.ini .vale.ini"

pe "cat .vale.ini"

pe "xdg-open 'https://vale.sh/docs/topics/styles/#built-in-style'"

# pe "vale ls-config | less"

pe "vale --no-wrap index.md"

pe "cp example-vale-config-files/example1.ini .vale.ini"

pe "cat .vale.ini"

pe "xdg-open 'https://github.com/errata-ai/packages?tab=readme-ov-file#available-styles'"

pe "mkdir -p .styles/"

pe "tree .styles"

pe "vale sync"

pe "tree .styles"

pe "less .styles/write-good/Cliches.yml"

pe "vale --no-wrap index.md"

# Add project Vocab

pe "cp example-vale-config-files/example2.ini .vale.ini"

pe "cat .vale.ini"

pe "mkdir -p .styles/config/vocabularies/ProjectVocab/"

echo "echo 'repos?' >> .styles/config/vocabularies/ProjectVocab/accept.txt"

pe "vale --no-wrap index.md"

# Switch off a rule

pe "cp example-vale-config-files/example3.ini .vale.ini"

pe "cat .vale.ini"

pe "vale --no-wrap index.md"

# Create our own spelling rules for AU English

pe "curl --output '.styles/config/dictionaries/en_AU.#1' --create-dirs \
  'https://raw.githubusercontent.com/LibreOffice/dictionaries/master/en/en_AU.{dic,aff}'"

pe "mkdir .styles/ProjectStyle"

cat > .styles/ProjectStyle/Spelling_AU.yml <<EOF
extends: spelling
level: error
message: "'%s' is not AU English"
dicpath: .styles/config/dictionaries
dictionaries:
  - en_AU
EOF

tree .styles

cat .styles/ProjectStyle/Spelling_AU.yml 

pe "cp example-vale-config-files/example4.ini .vale.ini"

pe "vale --no-wrap index.md"

