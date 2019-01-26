SITE := pedrohdz.com
S3_BUCKET := $(SITE)

PLANTUML_VERSION := 1.2019.0
PLANTUML_SHA256 := 767b2a3f5512ae0636fdaea8a54a58b96ffa8fd41933f941e6fb55bafed381e1

BUILD_DIR := build
VENV_DIR := $(BUILD_DIR)/venv
VENV_BIN_DIR := $(VENV_DIR)/bin
VENV_CONFIG_FILES := requirements.txt setup.cfg setup.py Makefile
PELICAN := ./$(VENV_BIN_DIR)/pelican
PIP := ./$(VENV_BIN_DIR)/pip3
AWS := ./$(VENV_BIN_DIR)/aws
BUMP_VERSION = ./$(VENV_BIN_DIR)/bump2version

export PATH := scripts:$(PATH)
export GRAPHVIZ_DOT := $(shell which dot)
ifeq (,$(GRAPHVIZ_DOT))
$(error Graphviz must be installed.)
endif


#------------------------------------------------------------------------------
# Common tasks
#------------------------------------------------------------------------------
all: pelican-build-local

.PHONY: clean clean-python clean-all directories prepare

clean:
	rm -Rf $(BUILD_DIR) output

clean-python:
	find . -name __pycache__ -prune -exec rm -Rf \{\} \;
	find . -name '*.egg-info' -prune -exec rm -Rf \{\} \;

clean-all: | clean clean-python

directories: $(BUILD_DIR)

$(BUILD_DIR):
	mkdir -p "$(BUILD_DIR)"

prepare: | venv-build plantuml-install


#------------------------------------------------------------------------------
# Python venv tasks
#------------------------------------------------------------------------------
VENV_BUILT_FLAG := $(BUILD_DIR)/venv-build-FLAG

.PHONY: venv-build venv-clean venv-update-freeze

venv-clean:
	rm -Rf \
		$(VENV_BUILT_FLAG) \
		$(VENV_DIR)

venv-build: $(VENV_BUILT_FLAG)
$(VENV_BUILT_FLAG): $(VENV_CONFIG_FILES) | directories
	python3 -m venv "$(VENV_DIR)"
	$(PIP) install --upgrade pip
	$(PIP) install \
		--upgrade \
		-e ./ext/pelican \
		-e . \
		-r requirements.txt
	touch $(VENV_BUILT_FLAG)

venv-update-freeze: | venv-build
	$(PIP) freeze --exclude-editable > requirements.txt


#------------------------------------------------------------------------------
# Bump version tasks
#------------------------------------------------------------------------------
.PHONY: bumpversion-patch bumpversion-minor bumpversion-major

bumpversion-patch: | venv-build
	$(BUMP_VERSION) patch

bumpversion-minor: | venv-build
	$(BUMP_VERSION) minor

bumpversion-major: | venv-build
	$(BUMP_VERSION) major


#------------------------------------------------------------------------------
# PlantUML tasks
#------------------------------------------------------------------------------
PLANTUML_VERSIONED_JAR_FILENAME := plantuml.$(PLANTUML_VERSION).jar
PLANTUML_BASE_URL := https://sourceforge.net/projects/plantuml/files
PLANTUML_URL := $(PLANTUML_BASE_URL)/$(PLANTUML_VERSIONED_JAR_FILENAME)
PLANTUML_VERSIONED_JAR := $(BUILD_DIR)/$(PLANTUML_VERSIONED_JAR_FILENAME)
PLANTUML_JAR := $(BUILD_DIR)/plantuml.jar
PLANTUML_PRECHECK_FILE := $(BUILD_DIR)/$(PLANTUML_VERSIONED_JAR_FILENAME).precheck
PLANTUML_SHA256_FILE := $(PLANTUML_PRECHECK_FILE).sha256sum

.PHONY: plantuml-install plantuml-docker-start plantuml-docker-stop

plantuml-install: $(PLANTUML_JAR)
$(PLANTUML_JAR): | directories
	wget \
		--no-verbose \
		--no-directories \
		--directory-prefix $(BUILD_DIR) \
		--output-document $(PLANTUML_PRECHECK_FILE) \
		$(PLANTUML_URL)
	echo "$(PLANTUML_SHA256)  $(PLANTUML_PRECHECK_FILE)" \
		> $(PLANTUML_SHA256_FILE)
	sha256sum -c $(PLANTUML_SHA256_FILE)
	mv $(PLANTUML_PRECHECK_FILE) $(PLANTUML_VERSIONED_JAR)
	ln -s $(PLANTUML_VERSIONED_JAR_FILENAME) $(PLANTUML_JAR)

plantuml-docker-start:
	docker run --rm --detach \
		--name pelican-plantuml \
		--publish 8001:8080 \
		plantuml/plantuml-server
	while ! curl http://localhost:8001/; do sleep 2; done
	open http://localhost:8001/

plantuml-docker-stop:
	docker stop pelican-plantuml


#------------------------------------------------------------------------------
# Pelican tasks
#------------------------------------------------------------------------------
PELICAN_BUILT_LOCAL_FLAG := $(BUILD_DIR)/pelican-build-local-FLAG
PELICAN_BUILT_PROD_FLAG := $(BUILD_DIR)/pelican-build-production-FLAG
CONTENT_FILES := $(shell find ./content/ -type f | sed -e 's/ /\\ /') \
				$(shell find ./theme-overrides/ -type f) \
				pelicanconf.py \
				publishconf.py

.PHONY: pelican-server pelican-build-production pelican-build-local \
	pelican-clean

pelican-clean:
	rm -Rf \
		output \
		$(PELICAN_BUILT_LOCAL_FLAG) \
		$(PELICAN_BUILT_PROD_FLAG)

pelican-server: | prepare
	$(PELICAN) \
		--verbose \
		--delete-output-directory \
		--autoreload \
		--listen

pelican-build-local: $(PELICAN_BUILT_LOCAL_FLAG)
$(PELICAN_BUILT_LOCAL_FLAG): $(CONTENT_FILES) $(VENV_CONFIG_FILES) | prepare
	$(PELICAN) \
		--verbose \
		--delete-output-directory
	touch $(PELICAN_BUILT_LOCAL_FLAG)

pelican-build-production: $(PELICAN_BUILT_PROD_FLAG)
$(PELICAN_BUILT_PROD_FLAG): $(CONTENT_FILES) $(VENV_CONFIG_FILES) | prepare
	$(PELICAN) \
		--verbose \
		--delete-output-directory \
		--settings publishconf.py
	touch $(PELICAN_BUILT_PROD_FLAG)


#------------------------------------------------------------------------------
# Deployment tasks
#------------------------------------------------------------------------------
.PHONY: deploy

deploy: | pelican-build-production
	$(AWS) s3 sync --delete \
		--exclude .DS_Store \
		./output/ \
		s3://$(S3_BUCKET)/

# vim: noexpandtab:tabstop=4:shiftwidth=4
