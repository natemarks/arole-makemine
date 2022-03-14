.DEFAULT_GOAL := help
DEFAULT_BRANCH := main

# Determine this makefile's path.
# Be sure to place this BEFORE `include` directives, if any.
THIS_FILE := $(lastword $(MAKEFILE_LIST))
VERSION := 0.0.2
#  use the long commit id
COMMIT := $(shell git rev-parse HEAD)
ROLE_DIRS := defaults files handlers meta playbook tasks templates test
#DEFAULT_BRANCH := $(shell git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')

help: ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

clean-venv: ## re-create virtual env
	rm -rf .venv
	python3 -m venv .venv
	( \
       . .venv/bin/activate; \
       pip install --upgrade pip setuptools pylint flake8 pytest pytest-testinfra; \
    )


clean_upload:
	@rm -rf packer/upload && mkdir -p packer/upload
	$(foreach var,$(ROLE_DIRS),cp -R $(var) packer/upload;)

base-images: clean_upload ## publish the AMI used to test this project
	( \
       . ./.env && cd packer && packer build \
			 -var-file="base-test-vars.hcl" base-test-images.pkr.hcl; \
    )

debug-base-images: clean_upload ## publish the AMI used to test this project
	( \
       . ./.env && cd packer && packer build -debug \
			 -var-file="base-test-vars.hcl" base-test-images.pkr.hcl; \
    )

test: clean_upload ## run packer test templates
	( \
       . ./.env && cd packer && packer build \
			 -var-file="base-test-vars.hcl" run-tests.pkr.hcl; \
    )

test-debug: clean_upload ## run packer test templates
	( \
       . ./.env && cd packer && packer build -debug \
			 -var-file="base-test-vars.hcl" run-tests.pkr.hcl; \
    )

clean-ansible: ## delete the $HOME/.ansible directory including galaxy-installed roles
	@rm -rf $${HOME}/.ansible

shellcheck: ## execute shellcheck
	   find . -type f -name "*.sh" -exec "shellcheck" "--format=gcc" {} \;

lint: shellcheck

git-status: ## require status is clean so we can use undo_edits to put things back
	@status=$$(git status --porcelain); \
	if [ ! -z "$${status}" ]; \
	then \
		echo "Error - working directory is dirty. Commit those changes!"; \
		exit 1; \
	fi

undo_edits: ## undo staged and unstaged change. ohmyzsh alias: grhh
	git reset --hard

rebase: git-status ## rebase current feature branch on to the default branch
	git fetch && git rebase origin/$(DEFAULT_BRANCH)

bump: ## bump version in main branch
ifeq ($(CURRENT_BRANCH), $(MAIN_BRANCH))
	( \
	   . .venv/bin/activate; \
	   pip install bump2version; \
	   bump2version $(part); \
	)
else
	@echo "UNABLE TO BUMP - not on Main branch"
	$(info Current Branch: $(CURRENT_BRANCH), main: $(MAIN_BRANCH))
endif

.PHONY: static shellcheck test clean_upload