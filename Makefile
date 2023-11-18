DOCKER_FILES := $(shell find './docker-compose' -type f -name \*\.yaml -exec echo -n ' -f {}' \;)

docker-up:
	docker-compose $(DOCKER_FILES) --env-file ./config/.env up -d

docker-config:
	docker-compose $(DOCKER_FILES) --env-file ./config/.env config

decrypt:
	poetry run python main.py sops decrypt ./encrypted ./decrypted

encrypt:
	poetry run python main.py sops encrypt ./decrypted ./encrypted

build: decrypt
	poetry run python main.py build ./decrypted ./build
