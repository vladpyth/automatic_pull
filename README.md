Команда	Описание
./run.sh	Обновить все проекты (клон+пулл+сборка+запуск)
./run.sh --project Eco_back_PONOinput	Обновить только один проект
./run.sh --help	Показать справку по всем командам
./run.sh --save-config config.json	Сохранить конфигурацию в файл
./run.sh --config config.json	Использовать конфигурацию из файла
Флаги управления
Флаг	Описание	Пример
--no-pull	Не делать git pull	./run.sh --no-pull
--no-rebuild	Не пересобирать образы	./run.sh --no-rebuild
--no-up	Только git pull, без запуска	./run.sh --no-up
--no-cache	Сборка без кэша	./run.sh --no-cache
--no-clone	Не клонировать новые проекты	./run.sh --no-clone
--force-recreate	Принудительно пересоздать контейнеры	./run.sh --force-recreate
--down	Остановить контейнеры перед обновлением	./run.sh --down
--remove-volumes	Удалить тома при остановке (только с --down)	./run.sh --down --remove-volumes
--add-repo	Добавить новый репозиторий	./run.sh --add-repo "Имя" "URL"
