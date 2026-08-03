# automatic_pull
# Клонировать отсутствующие проекты и обновить все
python3 ~/update_projects.py

# Обновить только один конкретный проект
python3 ~/update_projects.py --project Eco_back_PONOinput

# Обновить с принудительной пересборкой без кэша
python3 ~/update_projects.py --force-recreate --no-cache

# Остановить контейнеры, обновить код, пересобрать и запустить
python3 ~/update_projects.py --down --force-recreate

# Только клонировать отсутствующие проекты, не обновлять существующие
python3 ~/update_projects.py --no-pull --no-rebuild
