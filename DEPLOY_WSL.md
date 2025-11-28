# Деплой на WSL Ubuntu 24.04.01

Это руководство поможет развернуть Backend (FastAPI) и Frontend (React) на WSL Ubuntu 24.04.01.

## Предварительные требования

1. WSL Ubuntu 24.04.01 установлен и запущен
2. Проект скопирован в WSL или доступен через Windows файловую систему

## Быстрый старт

### Автоматическая установка

Запустите скрипт деплоя:

```bash
chmod +x deploy_wsl.sh
./deploy_wsl.sh
```

### Ручная установка

#### 1. Обновление системы

```bash
sudo apt update
sudo apt upgrade -y
```

#### 2. Установка Python и зависимостей

```bash
sudo apt install -y python3 python3-pip python3-venv python-is-python3
```

#### 3. Установка Node.js

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
node -v  # Проверка версии
```

#### 4. Установка Nginx

```bash
sudo apt install -y nginx
sudo systemctl status nginx  # Проверка статуса
```

## Настройка Backend

### 1. Подготовка окружения

**Вариант 1: Использовать скрипт (рекомендуется)**

```bash
chmod +x deploy/setup_venv.sh
sudo ./deploy/setup_venv.sh
```

**Вариант 2: Вручную**

```bash
cd /var/www/project/back

# Создайте venv с sudo (т.к. директория принадлежит www-data)
sudo python3 -m venv .venv

# Установите права
sudo chown -R www-data:www-data .venv
sudo chmod -R 755 .venv

# Установите зависимости
sudo .venv/bin/pip install --upgrade pip
sudo .venv/bin/pip install -r requirements.txt
```

### 2. Настройка переменных окружения

Создайте файл `back/.env` на основе `back/.env_example`:

```bash
cp back/.env_example back/.env
# Отредактируйте back/.env при необходимости
```

### 3. Тестовый запуск

```bash
cd back
source .venv/bin/activate
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

Проверьте в браузере: `http://localhost:8000/redoc`

Остановите сервер: `Ctrl+C`

### 4. Настройка systemd сервиса

Скопируйте файл сервиса:

```bash
sudo cp deploy/back.service /etc/systemd/system/
```

Настройте права доступа:

```bash
sudo mkdir -p /var/www/project
sudo cp -r back /var/www/project/
sudo chown -R www-data:www-data /var/www/project
```

Запустите сервис:

```bash
sudo systemctl daemon-reload
sudo systemctl start back.service
sudo systemctl enable back.service
sudo systemctl status back.service
```

Просмотр логов:

```bash
sudo journalctl -u back.service -f
```

Перезапуск сервиса:

```bash
sudo systemctl restart back.service
```

## Настройка Frontend

### 1. Установка зависимостей

```bash
cd front
npm install
```

### 2. Настройка переменных окружения

Файлы `.env` и `.env.production` уже созданы с настройками для localhost.

Для изменения API URL отредактируйте `front/.env.production`:

```bash
VITE_API_URL=http://localhost:8000/
```

### 3. Сборка проекта

```bash
cd front
npm run build
```

Собранные файлы будут в `front/dist/`

### 4. Копирование на сервер

```bash
sudo cp -r front /var/www/project/
sudo chown -R www-data:www-data /var/www/project/front
```

## Настройка Nginx

### 1. Создание конфигураций

Скопируйте конфигурационные файлы:

```bash
sudo cp deploy/back.conf /etc/nginx/sites-available/
sudo cp deploy/front.conf /etc/nginx/sites-available/
```

### 2. Включение сайтов

```bash
sudo ln -s /etc/nginx/sites-available/back.conf /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/front.conf /etc/nginx/sites-enabled/
```

### 3. Удаление дефолтной конфигурации (опционально)

```bash
sudo rm /etc/nginx/sites-enabled/default
```

### 4. Проверка и перезапуск

```bash
sudo nginx -t  # Проверка конфигурации
sudo systemctl restart nginx
```

## Доступ к приложению

После настройки приложение будет доступно:

- **Frontend**: `http://localhost/`
- **Backend API**: `http://localhost/` (через Nginx) или `http://localhost:8000/` (напрямую)
- **API Документация**: `http://localhost/redoc` или `http://localhost:8000/redoc`

## Получение IP-адреса WSL

Для доступа из Windows или других устройств в локальной сети:

```bash
hostname -I
```

Используйте этот IP вместо `localhost` в браузере.

## Управление сервисами

### Backend сервис

```bash
# Статус
sudo systemctl status back.service

# Запуск
sudo systemctl start back.service

# Остановка
sudo systemctl stop back.service

# Перезапуск
sudo systemctl restart back.service

# Логи
sudo journalctl -u back.service -f
```

### Nginx

```bash
# Статус
sudo systemctl status nginx

# Перезапуск
sudo systemctl restart nginx

# Проверка конфигурации
sudo nginx -t
```

## Обновление проекта

### Backend

```bash
cd /var/www/project/back
source .venv/bin/activate
git pull  # или скопируйте новые файлы
pip install -r requirements.txt
sudo systemctl restart back.service
```

### Frontend

```bash
cd front
npm install
npm run build
sudo cp -r dist/* /var/www/project/front/dist/
sudo chown -R www-data:www-data /var/www/project/front
```

## Решение проблем

### Ошибка: status=203/EXEC

Эта ошибка означает, что systemd не может найти или выполнить команду из `ExecStart`.

**Решение:**

1. Запустите скрипт диагностики:
```bash
chmod +x deploy/check_service.sh
sudo ./deploy/check_service.sh
```

2. Убедитесь, что виртуальное окружение создано:
```bash
cd /var/www/project/back
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

3. Проверьте, что uvicorn установлен:
```bash
ls -la /var/www/project/back/.venv/bin/uvicorn
```

4. Если файл не существует, установите зависимости:
```bash
cd /var/www/project/back
source .venv/bin/activate
pip install uvicorn fastapi
```

5. Попробуйте альтернативный вариант сервиса (использует `python -m uvicorn`):
```bash
sudo cp deploy/back.service.alt /etc/systemd/system/back.service
sudo systemctl daemon-reload
sudo systemctl start back.service
```

6. Проверьте права доступа:
```bash
sudo chown -R www-data:www-data /var/www/project
sudo chmod +x /var/www/project/back/.venv/bin/uvicorn
```

### Ошибка: No such file or directory '/var/www/project/back/app'

Если директория `app` не существует на сервере:

**Решение:**

1. Скопируйте backend на сервер:
```bash
chmod +x deploy/copy_backend.sh
sudo ./deploy/copy_backend.sh
```

2. Или вручную:
```bash
sudo mkdir -p /var/www/project
sudo cp -r /mnt/e/Python/FastAPI/10/back /var/www/project/
sudo chown -R www-data:www-data /var/www/project/back
```

3. Проверьте, что файлы скопированы:
```bash
ls -la /var/www/project/back/app
```

### Ошибка импорта модуля app.main

Если в логах видна ошибка `import_from_string` или `ModuleNotFoundError: No module named 'app'`:

**Решение:**

1. Убедитесь, что директория `app` существует:
```bash
ls -la /var/www/project/back/app
```

2. Если директории нет, скопируйте backend (см. выше).

3. Убедитесь, что в сервисе установлен `PYTHONPATH`:
```bash
# Проверьте файл сервиса
sudo cat /etc/systemd/system/back.service | grep PYTHONPATH
```

2. Если `PYTHONPATH` отсутствует, обновите сервис:
```bash
sudo cp deploy/back.service /etc/systemd/system/back.service
sudo systemctl daemon-reload
sudo systemctl restart back.service
```

3. Проверьте, что файл `.env` существует:
```bash
ls -la /var/www/project/back/.env
```

4. Если файл отсутствует, создайте его:

**Вариант 1: Использовать скрипт (рекомендуется)**
```bash
chmod +x deploy/setup_env.sh
sudo ./deploy/setup_env.sh
```

**Вариант 2: Вручную скопировать из исходного проекта**
```bash
# Скопируйте из исходной директории проекта
sudo cp /mnt/e/Python/FastAPI/10/back/.env_example /var/www/project/back/.env
sudo chown www-data:www-data /var/www/project/back/.env
sudo chmod 600 /var/www/project/back/.env

# Отредактируйте .env и установите необходимые переменные
sudo nano /var/www/project/back/.env
```

**Вариант 3: Создать вручную в директории сервера**
```bash
cd /var/www/project/back
sudo cp .env_example .env
sudo chown www-data:www-data .env
sudo nano .env
```

5. Протестируйте импорт вручную:
```bash
chmod +x deploy/test_backend.sh
sudo ./deploy/test_backend.sh
```

6. Проверьте формат .env файла:
```bash
chmod +x deploy/check_env.sh
sudo ./deploy/check_env.sh
```

7. Для полной диагностики используйте:
```bash
chmod +x deploy/debug_service.sh
sudo ./deploy/debug_service.sh
```

### Backend не запускается

1. Проверьте логи: `sudo journalctl -u back.service -n 50`
2. Проверьте права доступа: `sudo chown -R www-data:www-data /var/www/project`
3. Проверьте виртуальное окружение: `ls -la /var/www/project/back/.venv/bin/uvicorn`
4. Проверьте, что все зависимости установлены: `pip list | grep uvicorn`

### Nginx не работает

1. Проверьте конфигурацию: `sudo nginx -t`
2. Проверьте логи: `sudo tail -f /var/log/nginx/error.log`
3. Проверьте, что порт 80 не занят: `sudo netstat -tulpn | grep :80`

### Frontend не отображается

1. Проверьте, что сборка выполнена: `ls -la /var/www/project/front/dist/`
2. Проверьте права доступа: `sudo chown -R www-data:www-data /var/www/project/front`
3. Проверьте конфигурацию Nginx: `sudo nginx -t`

### Порт 8000 занят

Найдите процесс, использующий порт:

```bash
sudo lsof -i :8000
sudo kill -9 <PID>
```

## Дополнительные настройки

### Настройка firewall (если используется)

```bash
sudo ufw allow 80/tcp
sudo ufw allow 8000/tcp
sudo ufw status
```

### Автоматический запуск при старте WSL

Сервисы systemd должны запускаться автоматически. Если нет, проверьте:

```bash
sudo systemctl is-enabled back.service
sudo systemctl is-enabled nginx
```

## Примечания

- В WSL systemd может быть не включен по умолчанию. Если сервисы не запускаются, может потребоваться включить systemd в WSL.
- Для доступа из Windows используйте `localhost` или IP-адрес WSL.
- Для продакшена рекомендуется настроить HTTPS через Let's Encrypt (требует домен).

