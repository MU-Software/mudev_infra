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
	@(git add mudev_backend && git commit -m "Update submodule" && git push || true) && git stash pop

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
	@docker compose -f ./docker/all.yaml --env-file ./build/dotenv/docker_compose.env up -d --remove-orphans

docker-compose-upgrade:
	@docker compose -f ./docker/all.yaml --env-file ./build/dotenv/docker_compose.env pull
	@docker compose -f ./docker/all.yaml --env-file ./build/dotenv/docker_compose.env up -d --remove-orphans

docker-compose-logs:
	@docker compose -f ./docker/all.yaml --env-file ./build/dotenv/docker_compose.env logs -f

docker-compose-%:
	@docker compose -f ./docker/all.yaml --env-file ./build/dotenv/docker_compose.env $*

# Docker Stack
docker-stack-images:
	@docker compose -f ./docker/all.yaml --env-file ./.env.dummy config --resolve-image-digests \
	  | grep image \
	  | sed "s/image://" \
	  | awk '!seen[$$0]++' \
	  | awk '{$$1=$$1};1'

docker-stack-deploy:
	@docker compose -f ./docker/all.yaml --env-file ./build/dotenv/docker_compose.env config \
	| sed -e '/published:/ s/"//g' \
	| docker stack deploy --with-registry-auth --compose-file - mulab

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
