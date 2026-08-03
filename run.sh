#!/bin/bash
# Запуск pull_service.py  chmod +x ~/outomatic/automatic_pull/run.sh

cd "$(dirname "$0")"
python3 pull_service.py "$@"
