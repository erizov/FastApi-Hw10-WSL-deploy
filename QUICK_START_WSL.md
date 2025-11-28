# Быстрый старт деплоя на WSL

**ВАЖНО:** Все скрипты нужно запускать из исходной директории проекта (например, `/mnt/e/Python/FastAPI/10`), а не из `/var/www/project/back`!

## Шаг 1: Создайте .env файлы для Frontend

В WSL выполните:

```bash
# Перейдите в исходную директорию проекта
cd /mnt/e/Python/FastAPI/10  # или путь к вашему проекту

cd front
echo "VITE_API_URL=http://localhost:8000/" > .env
echo "VITE_API_URL=http://localhost:8000/" > .env.production
cd ..
```

## Шаг 2: Скопируйте Backend на сервер

```bash
# Убедитесь, что вы в исходной директории проекта
cd /mnt/e/Python/FastAPI/10

# Скопируйте backend
chmod +x deploy/copy_backend.sh
sudo ./deploy/copy_backend.sh
```

## Шаг 3: Настройте виртуальное окружение

```bash
# Все еще в исходной директории проекта
chmod +x deploy/setup_venv.sh
sudo ./deploy/setup_venv.sh
```

## Шаг 4: Настройте .env файл

```bash
chmod +x deploy/setup_env.sh
sudo ./deploy/setup_env.sh
```

## Шаг 5: Настройте systemd сервис

```bash
chmod +x deploy/fix_service.sh
sudo ./deploy/fix_service.sh
```

## Шаг 6: Настройте Nginx

```bash
sudo cp deploy/back.conf /etc/nginx/sites-available/
sudo cp deploy/front.conf /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/back.conf /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/front.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

## Шаг 7: Запустите сервис

```bash
sudo systemctl start back.service
sudo systemctl status back.service
```

## Готово!

Откройте в браузере:
- Frontend: http://localhost/
- Backend API: http://localhost/redoc

Подробная инструкция в файле `DEPLOY_WSL.md`

