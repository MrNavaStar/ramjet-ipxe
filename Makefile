.PHONY: clean
clean:
	rm -rf out/

.PHONY: build
build:
	@docker compose build
	@docker compose run --rm ipxe

.PHONY: image-build
image-build:
	@docker compose build

.PHONY: run
run: build
	@./qemu.sh

.PHONY: purge
purge: clean
	@docker compose down --rmi local --volumes --remove-orphans

.PHONY: rebuild
rebuild:
	@docker compose build --no-cache
	@docker compose run --rm ipxe