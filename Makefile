CMD_DIR := myapp
REGISTRY ?= bells17
PKG ?= github.com/bells17/go-template

GOOS ?= linux
GOVERSION ?= 1.13.12
BUILD_DIR := bin

ifeq ($(strip $(shell git status --porcelain 2>/dev/null)),)
GIT_TREE_STATE=clean
else
GIT_TREE_STATE=dirty
endif
COMMIT ?= $(shell git rev-parse HEAD)
VERSION ?= $(shell cat VERSION)
BUILD_DATE ?= $(shell date -u +'%Y-%m-%dT%H:%M:%SZ')

ifeq (,$(shell go env GOBIN))
GOBIN=$(shell go env GOPATH)/bin
else
GOBIN=$(shell go env GOBIN)
endif

LDFLAGS ?= -X $(PKG)/pkg/version.version=$(VERSION) -X $(PKG)/pkg/version.gitCommit=$(COMMIT) -X $(PKG)/pkg/version.gitTreeState=$(GIT_TREE_STATE) -X $(PKG)/pkg/version.buildDate=$(BUILD_DATE)


all: mkdir vendor clean compile build

.PHONY: deploy
deploy: clean compile build push

.PHONY: vendor
vendor:
	@GO111MODULE=on go mod download
	@GO111MODULE=on go mod tidy
	@GO111MODULE=on go mod vendor

.PHONY: clean
clean:
	@echo "==> Cleaning releases"
	@GOOS=$(GOOS) go clean -i -x ./...
	rm -f $(PWD)/$(BUILD_DIR)/$(CMD_DIR)

mkdir:
	@echo "==> Creating build directories"
	@mkdir -p $(BUILD_DIR)

.PHONY: compile
compile: mkdir
	@echo "==> Building the project"
	@docker run -v $(PWD):/go/src/$(PKG) \
	  -w /go/src/$(PKG) \
	  -e GOOS=$(GOOS) -e GOARCH=amd64 -e CGO_ENABLED=0 -e GOFLAGS=-mod=vendor golang:$(GOVERSION)-alpine3.12 \
	  go build -o $(BUILD_DIR)/$(CMD_DIR) -ldflags "$(LDFLAGS)" $(PKG)/cmd/$(CMD_DIR)/

.PHONY: build
build:
	@echo "==> Building the docker image"
	@docker build -t $(REGISTRY)/$(CMD_DIR):$(VERSION) .

.PHONY: push
push:
	@echo "==> Pushing the docker image"
	@docker push $(REGISTRY)/$(CMD_DIR):$(VERSION)

.PHONY: govet
govet:
	@go vet $(shell go list ./... | grep -v vendor)

.PHONY: golint
golint:
	@golint $(shell go list ./... | grep -v vendor)

.PHONY: gofmt
gofmt:
	@ci/gofmt.sh

.PHONY: test
test:
	@echo "==> Testing all packages"
	@go test -race $(shell go list ./... | grep -v vendor)
