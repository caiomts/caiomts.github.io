#!/usr/bin/env bash

PREFIX=''

[[ -d .venv ]] && PREFIX='.venv/bin/' && python -m venv .venv

[[ -d docs ]] ||  ${PREFIX}python -m mkdocs new .

${PREFIX}python -m mkdocs serve
