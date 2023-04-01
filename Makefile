.PHONY: bootstrap format docs

bootstrap:
	bash scripts/bootstrap.sh

docs:
	bash scripts/docs_preview.sh
