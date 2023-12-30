# Environment variable checker
guard-%:
	@if [ "${${*}}" = "" ]; then \
		echo "Environment variable $* not set"; \
		exit 1; \
	fi

# Backend submodule update
backend-update:
	@git stash --include-untracked
	@git submodule foreach git pull
	@(git commit -m "Update submodule" && git push || true) && git stash pop

# SOPS Encryption
sops-encrypt:
	@poetry run python main.py sops encrypt ./decrypted ./encrypted

sops-decrypt:
	@poetry run python main.py sops decrypt ./encrypted ./decrypted

# dotenv & service file generation
env-build: sops-decrypt
	@poetry run python main.py build ./decrypted ./build

env-build-with-error-ignored: sops-decrypt
	@poetry run python main.py build ./decrypted ./build --ignore-validation --ignore-error

# Docker Compose
docker-compose-up:
	@docker compose -f ./docker/all.yaml \
		--env-file ./build/dotenv/docker_compose.env \
		--env-file ./build/dotenv/mudev_backend.env \
		build \
		--build-arg GIT_HASH=$(shell git rev-parse HEAD) \
		--build-arg INVALIDATE_CACHE_DATE=$(shell date +%Y-%m-%d_%H:%M:%S)
	@docker compose -f ./docker/all.yaml --env-file ./build/dotenv/docker_compose.env up -d --remove-orphans

docker-compose-%:
	@docker compose -f ./docker/all.yaml --env-file ./build/dotenv/docker_compose.env $*

# Docker Stack
docker-stack-deploy:
	@docker compose -f ./docker/all.yaml --env-file ./build/dotenv/docker_compose.env config \
	| docker stack deploy --compose-file - mulab

docker-stack-ps:
	@docker stack ps mulab

docker-stack-rm:
	@docker stack rm mulab

docker-stack-services:
	@docker stack services mulab

# pre-commit hooks
hooks-install:
	@poetry run pre-commit install

hooks-upgrade:
	@poetry run pre-commit autoupdate

hooks-lint:
	@poetry run pre-commit run --all-files

lint: hooks-lint  # alias

hooks-mypy:
	@poetry run pre-commit run mypy --all-files

mypy: hooks-mypy  # alias
