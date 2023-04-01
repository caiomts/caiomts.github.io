#!/usr/bin/env bash

PREFIX=''

[[ -d .venv ]] && PREFIX='.venv/bin/' && python -m venv .venv

${PREFIX}python -m mkdocs gh-deploy --remote-branch master

