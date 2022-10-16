ARCHIVE_DIR       ?= $(BUILD_DIR)/artifacts

SITE              := pedrohdz.com
S3_BUCKET         := $(SITE)

PLANTUML_VERSION  := 1.2019.0
PLANTUML_SHA256   := 767b2a3f5512ae0636fdaea8a54a58b96ffa8fd41933f941e6fb55bafed381e1

BUILD_DIR         := build

VENV_DIR          := .venv
VENV_BIN_DIR      := $(VENV_DIR)/bin
VENV_CONFIG_FILES := requirements.txt Makefile
PELICAN           := $(VENV_BIN_DIR)/pelican
PIP               := $(VENV_BIN_DIR)/pip3
AWS               := $(VENV_BIN_DIR)/aws

export PATH         := scripts:$(PATH)
export GRAPHVIZ_DOT := $(shell which dot)


#------------------------------------------------------------------------------
# Common tasks
#------------------------------------------------------------------------------
all: pelican-build-production

.PHONY: clean distclean prepare

clean:
	rm -Rf $(BUILD_DIR)

distclean: | clean venv-clean pelican-clean

prepare: | venv-prepare pelican-prepare plantuml-prepare


#------------------------------------------------------------------------------
# Python venv tasks
#------------------------------------------------------------------------------
VENV_BUILT_FLAG := $(BUILD_DIR)/venv-prepare-FLAG

.PHONY: venv-prepare venv-clean venv-update-requirements

venv-clean:
	find . -name __pycache__ -prune -exec rm -Rf \{\} \;
	find . -name '*.egg-info' -prune -exec rm -Rf \{\} \;
	rm -Rf \
		$(VENV_BUILT_FLAG) \
		$(VENV_DIR)

venv-prepare: $(VENV_BUILT_FLAG)
$(VENV_BUILT_FLAG): $(VENV_CONFIG_FILES)
	mkdir -p $(@D)
	python3 -m venv "$(VENV_DIR)"
	$(PIP) install --upgrade pip setuptools wheel
	$(PIP) install --requirement requirements.txt
	touch $(VENV_BUILT_FLAG)

venv-update-requirements:
ifneq ($(wildcard $(VENV_DIR)),)
	$(error Python virtual environment must not be present: $(VENV_DIR))
endif
	python3 -m venv "$(VENV_DIR)"
	$(PIP) install --upgrade pip setuptools wheel
	$(PIP) install --upgrade \
		awscli \
		beautifulsoup4 \
		pelican[markdown] \
		pymdown-extensions
	$(PIP) freeze --exclude-editable > requirements.txt


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

.PHONY: plantuml-prepare plantuml-docker-start plantuml-docker-stop

plantuml-prepare: $(PLANTUML_JAR)
$(PLANTUML_JAR):
	mkdir -p $(@D)
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
BUILD_PREVIEW_SITE_DIR := $(BUILD_DIR)/site-dev
BUILD_PROD_SITE_DIR    := $(BUILD_DIR)/site-prod
CONTENT_FILES          := $(shell find ./content/ -type f | sed -e 's/ /\\ /') \
				$(shell find ./theme-overrides/ -type f) \
				pelicanconf.py \
				publishconf.py

.PHONY: pelican-live-preview pelican-build-production pelican-clean pelican-prepare

pelican-prepare:
ifeq (,$(GRAPHVIZ_DOT))
	$(error Graphviz must be installed.)
endif

pelican-clean:
	rm -Rf \
		$(BUILD_PREVIEW_SITE_DIR) \
		$(BUILD_PROD_SITE_DIR)

pelican-live-preview: | prepare pelican-prepare
	mkdir -p $(BUILD_PREVIEW_SITE_DIR)
	$(PELICAN) \
		--autoreload \
		--delete-output-directory \
		--listen \
		--output "$(BUILD_PREVIEW_SITE_DIR)" \
		--verbose

pelican-build-production: $(BUILD_PROD_SITE_DIR)
$(BUILD_PROD_SITE_DIR): $(CONTENT_FILES) $(VENV_CONFIG_FILES) | prepare pelican-prepare
	mkdir -p $(@D)
	tmp_dir=$$(mktemp --directory) \
		&& $(PELICAN) \
			--delete-output-directory \
			--output $$tmp_dir \
			--settings publishconf.py \
			--verbose \
		&& mv $$tmp_dir $@


#------------------------------------------------------------------------------
# Deployment tasks
#------------------------------------------------------------------------------
ARCHIVE_FILE  := $(ARCHIVE_DIR)/site-production.tgz
UNARCHIVE_DIR := $(BUILD_DIR)/site-prod-unarchived
DEPLOY_TAG    := $(shell date --utc '+release-%Y%m%d-%H%M')

.PHONY: archive deploy unarchive unarchive-clean deploy-tag-and-push

archive: $(ARCHIVE_FILE)
$(ARCHIVE_FILE): $(BUILD_PROD_SITE_DIR)
	mkdir -p $(@D)
	tar -zcvf $@ --directory=$(dir $<) $(notdir $<)

unarchive-clean:
	rm -Rf $(UNARCHIVE_DIR)

unarchive: $(UNARCHIVE_DIR)
$(UNARCHIVE_DIR):  # Do NOT make dependent on `archive`!
	mkdir -p $(@D)
	tmp_dir=$$(mktemp --directory) \
		&& tar -zxvf $(ARCHIVE_FILE) --directory=$$tmp_dir --strip-components 1 \
		&& mv -v $$tmp_dir/ $@/  # Trailing slashes are important!

deploy-verify:
	# TODO - Verify it can write, not just read.
	# Verify connection to S3 bucket.
	aws s3 ls s3://$(S3_BUCKET)/ > /dev/null

deploy-tag-and-push: | deploy-verify
	git tag --annotate $(DEPLOY_TAG) --message='Deployed via Makefile'
	git push origin $(DEPLOY_TAG)

deploy-from-archive: | unarchive venv-prepare deploy-tag-and-push
	# TODO - Upload a file with the version information.
	$(AWS) s3 sync \
		--delete \
		--exclude .DS_Store \
		./$(UNARCHIVE_DIR)/ \
		s3://$(S3_BUCKET)/

deploy-from-local-build: | pelican-build-production deploy-tag-and-push
	$(AWS) s3 sync \
		--delete \
		--exclude .DS_Store \
		./$(BUILD_PROD_SITE_DIR)/ \
		s3://$(S3_BUCKET)/

# vim: noexpandtab:tabstop=2:shiftwidth=2
