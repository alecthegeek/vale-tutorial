#!/bin/bash

# Setup

shopt -s expand_aliases

if type bat 2>&1 > /dev/null ; then
  alias cat="$(type -p bat)"
  unset LESS
fi

if type open 2>&1 > /dev/null ; then
  alias xdg-open=$(type -p open)
fi

rm -rf .git *.go go.mod .gitignore .lefthook.yaml Dockerfile .utils

direnv disallow

if [ ! -f demo-magic.sh ] ; then 
  echo Downloaing demo-magic from https:/sample/github.com/paxtonhare/demo-magic
  curl https://raw.githubusercontent.com/paxtonhare/demo-magic/master/demo-magic.sh -o demo-magic.sh
fi

brew install lefthook golangci-lint flock

source ./demo-magic.sh

clear

cat > go.mod <<'EOF'
module example/main

go 1.23.0
EOF

cat > main.go <<'EOF'
package main

import "fmt"

func greeting() string {
return `Hello World!`    
}

func main() {
fmt.Println(greeting())
}



EOF


cat > main_test.go <<'EOF'
package main

import "testing"

func TestHello(t *testing.T) {
	// Arrange
	expected := "Hello, World!"

	// Act
	actual := greeting() // Assuming main returns the printed string

	// Assert
	if actual != expected {
		t.Errorf("Unexpected output: got %q, want %q", actual, expected)
	}
}
EOF

printf "demo-magic.sh\ndemo.sh\n" > .gitignore

echo Hit Enter to Start

pe "cat main.go"

pe "cat main_test.go"

pe "git init"

pe "tree .git/hooks"

pe "cat .git/hooks/pre-commit.sample"

pe "mv .git/hooks/pre-commit.sample .git/hooks/pre-commit"

pe "git add *.go go.mod .gitignore"

pe "git commit -m 'Initial commit'"

pe "git status"

p "Let's talk about improvements"

pe "brew install lefthook"

cat > .lefthook.yaml <<'EOF'
pre-commit:
  parallel: true
  commands:
    fmt:
      glob: "*.go"
      run: flock -x /tmp/gotfmt.lock gofmt -l -w {staged_files}
      stage_fixed: true
    lint:
      glob: "*.go"
      run: flock -s /tmp/gotfmt.lock golangci-lint run {staged_files}
    test:
      glob: "*.go"
      run: flock -s /tmp/gotfmt.lock go test -cpu 24 -race -count=1 -timeout=30s example/main -run Hello

EOF

pe "cat .lefthook.yaml"

pe "brew install golangci-lint flock"

pe "lefthook install"

pe "cat .git/hooks/pre-commit"

pe "lefthook run pre-commit"

pe "git add .lefthook.yaml"

pe "git commit"

p "Now we get fancy with zero install using dekstop containers"

pe "brew uninstall lefthook golangci-lint flock"

cat > Dockerfile <<'EOF'
FROM golang:1.23.0-bullseye

ARG USER=developer

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends curl git && \
    useradd -m ${USER}

# https://github.com/evilmartians/lefthook/blob/master/docs/install.md
RUN curl -1sLf 'https://dl.cloudsmith.io/public/evilmartians/lefthook/setup.deb.sh' | bash  && \
    apt-get update  && \
    apt-get install -y lefthook

# binary will be $(go env GOPATH)/bin/golangci-lint
RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | \
    sh -s -- -b $(go env GOPATH)/bin v1.60.3

ENV GOLANGCI_LINT_CACHE=/tmp/golangci-lint-cache GOCACHE=/tmp/gocache

USER ${USER}

RUN mkdir -p ${GOLANGCI_LINT_CACHE} ; chmod -R 777 ${GOLANGCI_LINT_CACHE}
RUN mkdir -p ${GOCACHE} ; chmod -R 777 ${GOCACHE}

LABEL description="Toolkit for the demo of Lefthook"

LABEL maintainer="Alec Clews <alecclews@gmail.com>"

EOF

pe "cat Dockerfile"

pe "docker buildx build -t hooks_tools ."

mkdir .utils

cat > .utils/lefthook <<'EOF'
#!/bin/sh

IMAGE=hooks_tools

docker container run -i --rm \
    --mount "type=bind,source=$PWD,target=/data" \
    --workdir=/data \
    --user="$(id -u):$(id -g)" \
    --env="HOME=/home/developer" \
    --mount "type=volume,source=golangci-lint-cache,target=/tmp/golangci-lint-cache" \
    --mount "type=volume,source=gocache,target=/tmp/gocache" \
    "$IMAGE" lefthook "$@"

EOF

pe "cat .utils/lefthook"
pe "chmod +x .utils/lefthook"

pe 'export LEFTHOOK_BIN=$(PWD)/.utils/lefthook'

pe 'PATH=$PWD/.utils:$PATH'

pe "lefthook run pre-commit"

pe "git commit"

pe "nvim main.go"

pe "git add main.go"

pe "git commit -m 'Initial Commit'"

pe "git log"

