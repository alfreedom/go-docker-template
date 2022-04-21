.DEFAULT_GOAL := build

DOCKERFILE=Dockerfile
OUTPUT_PATH=bin/
PALTFORM=local
OUTPUT_BIN=hello
MODULE_NAME=myapp.com/m

.PHONY: build
build: dbuild

.PHONY: dbuild
dbuild:
	@docker build -f ${DOCKERFILE} . --target binary --output ${OUTPUT_PATH} --platform ${PALTFORM} --build-arg output_bin=${OUTPUT_BIN} --build-arg module_name=${MODULE_NAME}

.PHONY: clean
clean:
	rm -rf ${OUTPUT_PATH}/*

.PHONY: run
run:
	@./${OUTPUT_PATH}${OUTPUT_BIN} $(run_args)

.PHONY: test
test:
	@docker build -f ${DOCKERFILE} . --target unit-test

.PHONY: lint
lint:
	@docker build -f ${DOCKERFILE} . --target lint

.PHONY: init
init:
	@docker run --rm -v $(PWD):/go/src/app golang:1.18-alpine sh -c "cd src/app && go mod init ${MODULE_NAME} && go mod tidy"

.PHONY: clean_init
clean_init:
	@rm -rf go.mod go.sum

.PHONY: reinit
reinit: clean_init init

.PHONY: bash
bash:
	@docker run --rm -it -v $(PWD):/go/src/app golang:1.18-alpine sh

