#!/bin/bash
# Запуск pull_service.py

cd "$(dirname "$0")"
python3 pull_service.py "$@"
