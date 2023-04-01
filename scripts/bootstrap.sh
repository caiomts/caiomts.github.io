#!/usr/bin/env bash

set -x

PREFIX=''

[[ -z "$GITHUB_ACTIONS" ]] && PREFIX='.venv/bin/' && python -m venv .venv 

${PREFIX}python -m pip install --upgrade pip
${PREFIX}python -m pip install --requirement requirements.txt
