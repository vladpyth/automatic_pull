## 📚 Команды и их описание

### Основные команды

| Команда | Описание |
|---------|----------|
| `./run.sh` | Обновить все проекты (клон+пулл+сборка+запуск) |
| `./run.sh --project Eco_back_PONOinput` | Обновить только один проект |
| `./run.sh --help` | Показать справку по всем командам |
| `./run.sh --save-config config.json` | Сохранить конфигурацию в файл |
| `./run.sh --config config.json` | Использовать конфигурацию из файла |

---

### Флаги управления

| Флаг | Описание | Пример |
|------|----------|--------|
| `--no-pull` | Не делать git pull | `./run.sh --no-pull` |
| `--no-rebuild` | Не пересобирать образы | `./run.sh --no-rebuild` |
| `--no-up` | Только git pull, без запуска | `./run.sh --no-up` |
| `--no-cache` | Сборка без кэша | `./run.sh --no-cache` |
| `--no-clone` | Не клонировать новые проекты | `./run.sh --no-clone` |
| `--force-recreate` | Принудительно пересоздать контейнеры | `./run.sh --force-recreate` |
| `--down` | Остановить контейнеры перед обновлением | `./run.sh --down` |
| `--remove-volumes` | Удалить тома при остановке (только с --down) | `./run.sh --down --remove-volumes` |
| `--add-repo` | Добавить новый репозиторий | `./run.sh --add-repo "Имя" "URL"` |

---

### Комбинации команд

| Команда | Описание |
|---------|----------|
| `./run.sh --project Eco_back_PONOinput --force-recreate` | Пересоздать только один проект |
| `./run.sh --no-pull --no-cache --force-recreate` | Пересобрать без кэша и без git pull |
| `./run.sh --down --remove-volumes --force-recreate` | Полная перезагрузка проекта |
| `./run.sh --project Eco_back_PONOd --no-up` | Обновить код, но не запускать контейнеры |
| `./run.sh --no-clone --no-pull --no-rebuild` | Только запустить существующие контейнеры |

---

### Дополнительные команды

| Команда | Описание |
|---------|----------|
| `./run.sh --add-repo "Название" "URL"` | Добавить репозиторий в конфигурацию |
| `./run.sh --add-repo "Название" "URL" --save-config config.json` | Добавить репозиторий и сохранить конфиг |
| `./run.sh --path ~/my_projects` | Использовать другую папку для проектов |
| `./run.sh --config config.json` | Использовать конфигурацию из JSON файла |

---

### Быстрые алиасы

| Алиас | Команда | Описание |
|-------|---------|----------|
| `eco-update` | `~/outomatic/automatic_pull/pull_service/run.sh` | Быстрое обновление |
| `eco-update-all` | `~/outomatic/automatic_pull/pull_service/run.sh --force-recreate` | Полная пересборка |
| `eco-update-log` | `tail -f ~/outomatic/automatic_pull/pull_service/pull_service.log` | Просмотр логов |

---

### Таблица ошибок и решений

| Ошибка | Решение |
|--------|---------|
| `Permission denied` | `chmod +x pull_service.py run.sh` |
| `docker: command not found` | Установите Docker: `curl -fsSL https://get.docker.com \| sh` |
| `git: command not found` | Установите Git: `sudo apt install git -y` |
| Контейнеры не запускаются | Проверьте: `docker compose logs` |
| Нет места на диске | Очистите: `docker system prune -a -f` |

---

### Логирование

| Команда | Описание |
|---------|----------|
| `tail -50 pull_service.log` | Просмотр последних 50 строк лога |
| `tail -f pull_service.log` | Слежение за логами в реальном времени |
| `grep ERROR pull_service.log` | Поиск ошибок в логах |
| `cat pull_service.log \| wc -l` | Количество строк в логе |
