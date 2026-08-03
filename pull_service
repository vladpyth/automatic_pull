#!/usr/bin/env python3
"""
Скрипт для автоматического обновления и клонирования Docker проектов
из GitHub репозиториев в директорию ~/Eco
"""

import os
import subprocess
import sys
from pathlib import Path
from datetime import datetime
import argparse
import logging
import json
from typing import Dict, List, Optional

# Настройка логирования
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger(__name__)

# Цвета для терминала
class Colors:
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    BLUE = '\033[94m'
    MAGENTA = '\033[95m'
    CYAN = '\033[96m'
    RESET = '\033[0m'

class DockerProjectManager:
    def __init__(self, base_path=None, config_file=None):
        """
        Инициализация менеджера проектов
        
        Args:
            base_path: путь к директории с проектами (по умолчанию ~/Eco)
            config_file: путь к JSON файлу с конфигурацией репозиториев
        """
        if base_path is None:
            self.base_path = Path.home() / "Eco"
        else:
            self.base_path = Path(base_path).expanduser()
            
        self.base_path.mkdir(exist_ok=True)
        
        # Конфигурация репозиториев по умолчанию
        self.default_repos = {
            "Eco_back_PONOd": "https://github.com/vladpyth/Eco_back_PONOd.git",
            "Eco_back_PONOinput": "https://github.com/vladpyth/Eco_back_PONOinput.git",
            "Eco_back_POO": "https://github.com/vladpyth/Eco_back_POO.git",
            "Eco_back_RXZO": "https://github.com/vladpyth/Eco_back_RXZO.git",
            "Eco_fronte": "https://github.com/vladpyth/Eco_fronte.git",
            "Eco_portal": "https://github.com/vladpyth/Eco_portal.git"
        }
        
        # Загружаем конфигурацию из файла если есть
        self.repos = self.load_config(config_file) if config_file else self.default_repos
        
        self.projects = []
        self.failed_projects = []
        self.successful_projects = []
        self.cloned_projects = []
        
    def load_config(self, config_file: str) -> Dict:
        """Загружает конфигурацию репозиториев из JSON файла"""
        try:
            with open(config_file, 'r') as f:
                config = json.load(f)
                return config.get('repositories', self.default_repos)
        except Exception as e:
            logger.warning(f"Не удалось загрузить конфиг: {e}, использую настройки по умолчанию")
            return self.default_repos
    
    def save_config(self, config_file: str):
        """Сохраняет текущую конфигурацию в JSON файл"""
        config = {
            'repositories': self.repos,
            'base_path': str(self.base_path)
        }
        with open(config_file, 'w') as f:
            json.dump(config, f, indent=2)
        logger.info(f"Конфигурация сохранена в {config_file}")
    
    def find_projects(self):
        """Поиск всех проектов с docker-compose.yml в базовой директории"""
        logger.info(f"{Colors.BLUE}Поиск проектов в {self.base_path}{Colors.RESET}")
        
        if not self.base_path.exists():
            logger.warning(f"Директория {self.base_path} не существует, создаю...")
            self.base_path.mkdir(parents=True)
            return False
            
        # Рекурсивно ищем все docker-compose.yml файлы
        compose_files = list(self.base_path.rglob("docker-compose.yml"))
        compose_files.extend(self.base_path.rglob("docker-compose.yaml"))
        
        # Получаем уникальные директории проектов
        self.projects = sorted(set(f.parent for f in compose_files))
        
        logger.info(f"{Colors.GREEN}Найдено локальных проектов: {len(self.projects)}{Colors.RESET}")
        for project in self.projects:
            logger.info(f"  - {project.name}")
            
        return True
    
    def clone_repository(self, repo_name: str, repo_url: str) -> bool:
        """
        Клонирует репозиторий из GitHub
        
        Args:
            repo_name: имя папки для проекта
            repo_url: URL репозитория
        """
        project_path = self.base_path / repo_name
        
        if project_path.exists():
            logger.info(f"{Colors.YELLOW}Проект {repo_name} уже существует{Colors.RESET}")
            return True
            
        logger.info(f"{Colors.CYAN}Клонирование {repo_name} из {repo_url}{Colors.RESET}")
        
        try:
            result = subprocess.run(
                ["git", "clone", repo_url, str(project_path)],
                capture_output=True,
                text=True,
                timeout=120
            )
            
            if result.returncode != 0:
                logger.error(f"Ошибка клонирования: {result.stderr}")
                return False
                
            logger.info(f"{Colors.GREEN}✓ Проект {repo_name} успешно клонирован{Colors.RESET}")
            self.cloned_projects.append(repo_name)
            return True
            
        except subprocess.TimeoutExpired:
            logger.error(f"Клонирование превысило таймаут")
            return False
        except Exception as e:
            logger.error(f"Ошибка при клонировании: {e}")
            return False
    
    def ensure_all_repos_cloned(self):
        """Проверяет и клонирует все недостающие репозитории"""
        logger.info(f"{Colors.BLUE}Проверка наличия всех репозиториев...{Colors.RESET}")
        
        for repo_name, repo_url in self.repos.items():
            project_path = self.base_path / repo_name
            if not project_path.exists():
                logger.info(f"Репозиторий {repo_name} отсутствует, клонируем...")
                if not self.clone_repository(repo_name, repo_url):
                    self.failed_projects.append((repo_name, "не удалось клонировать"))
            else:
                logger.info(f"{Colors.GREEN}✓ {repo_name} уже есть{Colors.RESET}")
    
    def git_pull(self, project_path: Path) -> bool:
        """Выполняет git pull в проекте"""
        try:
            # Проверяем, является ли директория git репозиторием
            git_dir = project_path / ".git"
            if not git_dir.exists():
                logger.warning(f"  {Colors.YELLOW}Не git репозиторий, пропускаем pull{Colors.RESET}")
                return True
                
            logger.info(f"  Выполняю git pull...")
            result = subprocess.run(
                ["git", "pull"],
                cwd=project_path,
                capture_output=True,
                text=True,
                timeout=60
            )
            
            if result.returncode != 0:
                logger.warning(f"  Git pull предупреждение: {result.stderr}")
                return True
                
            if "Already up to date" in result.stdout:
                logger.info(f"  {Colors.YELLOW}Уже обновлено{Colors.RESET}")
            else:
                # Показываем что изменилось
                if "changed" in result.stdout or "insertion" in result.stdout:
                    logger.info(f"  {Colors.GREEN}Обновлено из git:{Colors.RESET}")
                    for line in result.stdout.split('\n'):
                        if any(x in line for x in ['changed', 'insertion', 'deletion']):
                            logger.info(f"    {line.strip()}")
            return True
            
        except subprocess.TimeoutExpired:
            logger.error(f"  Git pull превысил таймаут")
            return False
        except Exception as e:
            logger.error(f"  Ошибка git pull: {e}")
            return False
    
    def docker_compose_up(self, project_path: Path, rebuild: bool = False, 
                         force_recreate: bool = False, no_cache: bool = False) -> bool:
        """Запускает docker compose up в проекте"""
        try:
            cmd = ["docker", "compose", "up", "-d"]
            
            if rebuild:
                cmd.append("--build")
                if no_cache:
                    cmd.append("--no-cache")
                logger.info(f"  Сборка образов...")
                
            if force_recreate:
                cmd.append("--force-recreate")
                logger.info(f"  Принудительное пересоздание контейнеров...")
                
            logger.info(f"  Запуск контейнеров...")
            
            result = subprocess.run(
                cmd,
                cwd=project_path,
                capture_output=True,
                text=True,
                timeout=180
            )
            
            if result.returncode != 0:
                logger.error(f"  {Colors.RED}Ошибка запуска:{Colors.RESET}")
                logger.error(f"  {result.stderr}")
                return False
                
            logger.info(f"  {Colors.GREEN}✓ Контейнеры запущены{Colors.RESET}")
            return True
            
        except subprocess.TimeoutExpired:
            logger.error(f"  Docker compose превысил таймаут")
            return False
        except Exception as e:
            logger.error(f"  Ошибка docker compose: {e}")
            return False
    
    def docker_compose_down(self, project_path: Path, remove_volumes: bool = False) -> bool:
        """Останавливает контейнеры в проекте"""
        try:
            cmd = ["docker", "compose", "down"]
            if remove_volumes:
                cmd.append("-v")
                logger.info(f"  Удаление томов...")
                
            logger.info(f"  Остановка контейнеров...")
            
            result = subprocess.run(
                cmd,
                cwd=project_path,
                capture_output=True,
                text=True,
                timeout=60
            )
            
            if result.returncode != 0:
                logger.warning(f"  Предупреждение при остановке: {result.stderr}")
                return False
                
            logger.info(f"  {Colors.GREEN}✓ Контейнеры остановлены{Colors.RESET}")
            return True
            
        except Exception as e:
            logger.error(f"  Ошибка при остановке: {e}")
            return False
    
    def update_project(self, project_path: Path, options) -> bool:
        """Обновляет один проект"""
        project_name = project_path.name
        logger.info(f"\n{Colors.BLUE}=== Обработка: {project_name} ==={Colors.RESET}")
        
        # Шаг 1: Остановка если нужно
        if options.down:
            self.docker_compose_down(project_path, options.remove_volumes)
        
        # Шаг 2: git pull
        if options.pull:
            if not self.git_pull(project_path):
                self.failed_projects.append((project_name, "git pull failed"))
                return False
        
        # Шаг 3: docker compose up
        if options.up:
            if not self.docker_compose_up(
                project_path, 
                rebuild=options.rebuild,
                force_recreate=options.force_recreate,
                no_cache=options.no_cache
            ):
                self.failed_projects.append((project_name, "docker up failed"))
                return False
        
        self.successful_projects.append(project_name)
        return True
    
    def update_all(self, options):
        """Обновляет все проекты"""
        # Сначала клонируем все недостающие репозитории
        if options.clone_missing:
            self.ensure_all_repos_cloned()
        
        # Находим все проекты
        self.find_projects()
        
        if not self.projects:
            logger.warning("Нет проектов для обновления")
            return False
            
        logger.info(f"{Colors.BLUE}Начинаю обновление {len(self.projects)} проектов{Colors.RESET}")
        start_time = datetime.now()
        
        for project_path in self.projects:
            # Проверяем, нужно ли обновлять конкретный проект
            if options.project and project_path.name != options.project:
                continue
            self.update_project(project_path, options)
            
        # Выводим итоговый отчет
        self.print_summary(start_time)
        return True
    
    def print_summary(self, start_time):
        """Выводит итоговый отчет"""
        elapsed = datetime.now() - start_time
        total = len(self.projects)
        success = len(self.successful_projects)
        failed = len(self.failed_projects)
        
        logger.info(f"\n{Colors.BLUE}=== ИТОГОВЫЙ ОТЧЕТ ==={Colors.RESET}")
        logger.info(f"Всего проектов: {total}")
        
        if self.cloned_projects:
            logger.info(f"{Colors.CYAN}Клонировано проектов: {len(self.cloned_projects)}{Colors.RESET}")
            for name in self.cloned_projects:
                logger.info(f"  - {name}")
        
        logger.info(f"{Colors.GREEN}Успешно обновлено: {success}{Colors.RESET}")
        
        if failed > 0:
            logger.info(f"{Colors.RED}Ошибок: {failed}{Colors.RESET}")
            for name, error in self.failed_projects:
                logger.info(f"  - {name}: {error}")
        else:
            logger.info(f"{Colors.GREEN}Все проекты обновлены успешно! 🎉{Colors.RESET}")
            
        logger.info(f"Время выполнения: {elapsed.total_seconds():.2f} сек")


def main():
    parser = argparse.ArgumentParser(
        description="Управление Docker проектами из GitHub репозиториев",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Примеры использования:
  %(prog)s                    # Клонировать отсутствующие и обновить все проекты
  %(prog)s --no-pull          # Пересобрать без git pull
  %(prog)s --no-rebuild       # Обновить без пересборки
  %(prog)s --project Eco_back_PONOinput  # Обновить только один проект
  %(prog)s --down             # Остановить контейнеры перед обновлением
  %(prog)s --save-config      # Сохранить текущую конфигурацию в файл
        """
    )
    
    parser.add_argument(
        "--path",
        type=str,
        default="~/Eco",
        help="Путь к директории с проектами (по умолчанию: ~/Eco)"
    )
    
    parser.add_argument(
        "--config",
        type=str,
        help="Путь к JSON файлу с конфигурацией репозиториев"
    )
    
    parser.add_argument(
        "--save-config",
        type=str,
        help="Сохранить конфигурацию в указанный файл"
    )
    
    parser.add_argument(
        "--no-pull",
        action="store_true",
        help="Не выполнять git pull"
    )
    
    parser.add_argument(
        "--no-rebuild",
        action="store_true",
        help="Не пересобирать образы (только запуск)"
    )
    
    parser.add_argument(
        "--force-recreate",
        action="store_true",
        help="Принудительно пересоздать контейнеры"
    )
    
    parser.add_argument(
        "--no-cache",
        action="store_true",
        help="Не использовать кэш при сборке (--no-cache)"
    )
    
    parser.add_argument(
        "--no-up",
        action="store_true",
        help="Только git pull, не запускать контейнеры"
    )
    
    parser.add_argument(
        "--down",
        action="store_true",
        help="Остановить контейнеры перед обновлением"
    )
    
    parser.add_argument(
        "--remove-volumes",
        action="store_true",
        help="Удалить тома при остановке (только с --down)"
    )
    
    parser.add_argument(
        "--no-clone",
        action="store_true",
        help="Не клонировать отсутствующие репозитории"
    )
    
    parser.add_argument(
        "--project",
        type=str,
        help="Обновить только конкретный проект (по имени папки)"
    )
    
    parser.add_argument(
        "--add-repo",
        nargs=2,
        metavar=("NAME", "URL"),
        help="Добавить репозиторий в конфигурацию (имя URL)"
    )
    
    args = parser.parse_args()
    
    # Создаем менеджер
    manager = DockerProjectManager(args.path, args.config)
    
    # Добавляем репозиторий если указан
    if args.add_repo:
        name, url = args.add_repo
        manager.repos[name] = url
        logger.info(f"Добавлен репозиторий: {name} -> {url}")
        if args.save_config:
            manager.save_config(args.save_config)
        return
    
    # Сохраняем конфигурацию если нужно
    if args.save_config:
        manager.save_config(args.save_config)
        return
    
    # Настройка опций
    class Options:
        def __init__(self, args):
            self.pull = not args.no_pull
            self.rebuild = not args.no_rebuild
            self.force_recreate = args.force_recreate
            self.no_cache = args.no_cache
            self.up = not args.no_up
            self.down = args.down
            self.remove_volumes = args.remove_volumes
            self.clone_missing = not args.no_clone
            self.project = args.project
    
    options = Options(args)
    
    # Запускаем обновление
    success = manager.update_all(options)
    if not success:
        sys.exit(1)


if __name__ == "__main__":
    main()
