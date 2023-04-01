#!/usr/bin/env bash

PREFIX=''

[[ -d .venv ]] && PREFIX='.venv/bin/'

${PREFIX}python -m mkdocs gh-deploy --remote-branch master

