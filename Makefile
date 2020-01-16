ifeq ($(CI), 'true')
  ifndef exec_args
    exec_args='-T'
  endif
endif

ifndef CI_COMMIT_REF_SLUG
  CI_COMMIT_REF_SLUG := `git branch | grep \* | cut -d ' ' -f2 | sed 's/\//-/g' | tr '[:upper:]' '[:lower:]'`
endif

ifndef $(BUILD_TAG)
	BUILD_TAG := $(CI_COMMIT_REF_SLUG)
endif

APP_NAME=docker.pkg.github.com/viktorprogger/rss-telegram-bot/bot

BRANCH_DEFAULT=master

.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

echo-build-tag:
	@echo "Current tag for images is $(CI_COMMIT_REF_SLUG)"


build: ## Build an image for bot service and tag it within the branch name
	@docker build --pull -t $(APP_NAME):$(CI_COMMIT_REF_SLUG) -f .docker/php/Dockerfile ./src
	@if test "$(CI_COMMIT_REF_SLUG)" = "$(BRANCH_DEFAULT)"  ; \
		then docker tag $(APP_NAME):$(CI_COMMIT_REF_SLUG) $(APP_NAME):latest ; \
	fi

publish: build tag push ## Build an image, tag it and publish to the registry

push: ## Push an existent image to the registry
	@docker push $(APP_NAME)

tag: ## Add tags to the bot service
	@for a_tag in $$(git tag --points-at HEAD) ; do \
		echo "Tagging image '$(APP_NAME)' with tag '$$a_tag'"; \
		docker tag $(APP_NAME):$(CI_COMMIT_REF_SLUG) $(APP_NAME):$$a_tag ; \
	done

up: ## Bring up docker-compose services in dev mode (code is a volume and DB is not, xdebug is enabled)
	@BUILD_TAG=$(BUILD_TAG) docker-compose up -d --remove-orphans $(args)

up-test: ## Bring up docker-compose services in testing mode (DB and code are NOT volumes, xdebug is disabled)
	@BUILD_TAG=$(BUILD_TAG) docker-compose -f docker-compose.ci.yml up -d --remove-orphans $(args)

up-prod: ## Bring up docker-compose services in production mode (DB is a volume, xdebug is disabled)
	@BUILD_TAG=$(BUILD_TAG) docker-compose -f docker-compose.prod.yml up -d --remove-orphans $(args)

pull: ## Pull all new images listed in docker-compose
	@BUILD_TAG=$(BUILD_TAG) docker-compose -f docker-compose.ci.yml pull

down: ## Put the docker-compose services down
	@docker-compose down

run: ## Use `docker-compose run` within the bot container (it may be down). See https://docs.docker.com/compose/reference/run/
	@BUILD_TAG=$(BUILD_TAG) docker-compose run --rm $(exec_args) bot $(c)

exec-db: ## Use `docker-compose exec` within the db container
	@BUILD_TAG=$(BUILD_TAG) docker-compose exec $(exec_args) db $(c)

db-refresh: ## non-interactively refresh the database structure
	@exec_args=-T make exec c="php yii migrate/fresh --interactive=0"

yii: ## Execute `php yii some/command` in the php container
	@make run c="php ./yii $(c)"
