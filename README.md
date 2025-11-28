# 10 Деплой Backend и Frontend

## Описание темы

В этом мини-модуле слушатели изучают процесс развёртывания веб-приложений на виртуальных серверах (VPS/VDS) с использованием FastAPI (backend) и React SPA (frontend). Основное внимание уделяется безопасной настройке сервера, подготовке приложений к продакшену, организации автоматического запуска и доступу через домены с HTTPS.

Ключевая особенность — интеграция всех компонентов в единое продакшен-окружение, где Backend и Frontend работают синхронно, обеспечивая пользователю быстрый и безопасный доступ к сервису, а администратору — удобное управление и масштабирование проекта.

В рамках темы слушатели научатся настраивать VPS/VDS, работать с SSH-ключами для удалённого доступа, запускать FastAPI через Uvicorn с systemd, готовить React-проект для продакшена и раздавать его через Nginx, а также подключать домены и защищать сайт с помощью TLS-сертификатов Let’s Encrypt.

## Цели освоения темы

- Освоить основы работы с VPS/VDS, включая настройку и управление сервером.
- Научиться использовать SSH-ключи для безопасного подключения из VS Code и удалённого управления сервером.
- Настроить FastAPI в продакшене через Uvicorn и systemd, обеспечивая автоматический запуск и логирование.
- Подготовить React SPA к продакшену с помощью npm run build и настроить его раздачу через Nginx.
- Научиться связывать FrontEnd и BackEnd через домены, организовывать маршрутизацию и защищённое HTTPS-соединение через Let’s Encrypt.

## В результате освоения темы можно

- Развернуть полноценный продакшен-сервер для FastAPI и React SPA.
- Настроить автоматический запуск Backend через systemd и безопасный доступ к серверу по SSH.
- Подготовить и оптимизировать фронтенд React для продакшена и раздавать его через Nginx с кэшированием и gzip.
- Организовать корректную работу доменов для FrontEnd и BackEnd, обеспечив безопасное взаимодействие API и клиентской части.
- Настроить бесплатные TLS-сертификаты Let’s Encrypt и автоматическое обновление для обеспечения HTTPS и доверия пользователей.

## Место в курсе

Этот модуль является логическим продолжением финального мини-проекта и показывает, как перенести локально разработанное приложение в продакшен. Он объединяет навыки работы с сервером, настройкой сервисов, оптимизацией фронтенда, маршрутизацией и безопасностью, что позволяет слушателям создавать полностью работоспособные и безопасные веб-сервисы, готовые к эксплуатации в реальном интернете.

## Инструкция по размещению проекта на облачном сервере

Для примера в инструкции представлено размещение проекта в операционной системе "Ubuntu 24" (вид операционной системы рассматривать как пример) у хостинг провайдера "BEGET" (провайдера рассматривать как пример) по IP-адресу 84.54.29.221 (IP-адрес рассматривать как пример) с подключением доменов: https://api.union-ai.ru - для BackEnd и https://union-ai.ru - для FrontEnd (рассматривать имена доменов как пример).

### Сбор в один каталог
1. Создайте каталог project.
2. В каталог project скопируйте приложение backend в каталог project/back.
3. В каталог project скопируйте приложение frontend в каталог project/front.

### Регистрация на Beget
1. Перейдите по ссылке:
```
beget.com/p1023067
```
2. В окне регистрации выберите тариф "Cloud".
3. Если вы физлицо, то заполните ФИО, мобильный телефон, e-mail, можно указать предпочитаемый логин, если он не занят.
4. Если вы юрлицо - нажмите вкладку "Юридическое лицо" и заполните соответствующие поля.
5. Нажмите кнопку "РЕГИСТРАЦИЯ".

### Создание VPS

1. В панели управления хостингом выберите "Создать виртуальный сервер".
2. Выберите параметры:
- процессор 1 ядро;
- оперативная память 3Gb;
- диск 10Gb.
3. Выберите операционную систему "Ubuntu 24".
4. Нажмите "Задать пароль", введите предпочитаемый пароль.
5. Дополнительные параметры сервера:
- предпочитаемое название виртуального сервера;
- открыть доступ к файлам сервера через файловый менеджер: да;
- подключить сервер к приватной сети: нет.
6. Нажмите "Создать виртуальный сервер".

### Создание ключей SSH

1. Скачайте программу Putty, в комплекте с утилитой "Putty key generator".
2. Запустите утилиту "Putty key generator".
3. Нажмите кнопку "Generate". Двигайте мышкой по окну программы, пока не заполнится прогресс бар.
4. Полностью скопируйте в буфер обмена содержмое поля "Public key for pasting into OpenSSH authorized_keys file:".
5. Создайте файл открытого ключа 84.54.29.221.public, в него скопируйте содержимое буфера обмена, сохраните. Обратите внимание, что если вы создадите файл через кнопку "Save public key", то формат файла может не подойти для сервера.
6. Нажмите кнопку "Save private key", сохраните закрытый ключ в файл 84.54.29.221.ppk
7. В меню выберите "Conversion" -> "Export OpenSSH key", сохраните закрытый ключ в формате OpenSSH в файл 84.54.29.221.openssh.

### Подключение VS Code к серверу

1. На панели управления Beget откройте файловый менеджер.
2. Откройте в файловом менеджере в редакторе файл /root/.ssh/authorized_keys
3. Скопируйте через буфер обмена содержимое файла 84.54.29.221.public во вторую строку файла /root/.ssh/authorized_keys и сохраните файл. Обратите внимание, что существующие строки нужно оставить без изменений.
4. Откройте редактор VS Code.
5. Установите расширение "Remote - SSH".
6. В левом вертикальном меню редактора нажмите иконку "Удаленный обозреватель".
7. В дереве объектво Наведидте мышь на строку SSH и нажмите на шестеренку.
8. Сверку в списке выберите файл C:\Users\ИмяПользователя\config
9. Средствами проводника скопируйте файл 84.54.29.221.openssh в каталог c:\Users\ИмяПользователя\.ssh\
- Обратите внимание, что если каталога .ssh нет, то создайте его средствами проводника.
10. В редакторе VS Code добавьте в конце файла строки:
```
Host 84.54.29.221
  HostName 84.54.29.221
  User root
  ForwardAgent yes
  IdentityFile c:\Users\ИмяПользователя\.ssh\84.54.29.221.openssh
```
- Обратите внимание, что "ИмяПользователя" такое, как у вас на компьютере.
- Сохраните файл настроек.
11. В удаленном обозревателе появится строка 84.54.29.221, наведите на нее мышь, появится стрелка вправо, нажмите на стрелку.
12. Сверху выберите "Linux", затем "Продолжить".
13. Нажмите "Открыть папку", выберите "/var/", нажмите ОК. Затем "Да доверяю".
14. Слева в корне создайте каталог www.

### Подготовка Backend к продакшен

В файле project/back/app/main.py замените:
```
app = FastAPI(title="Lead & Assistant API", lifespan=lifespan, debug=True)
```
на
```
app = FastAPI(title="Lead & Assistant API", lifespan=lifespan, debug=False)
```

### Подготовка Frontend к продакшен

1. Создайте файл project/front/.env с содержимым:
```
VITE_API_URL=http://localhost:8000/
```
2. Создайте файл project/front/.env.production с содержимым:
```
VITE_API_URL=https://api.union-ai.ru/
```
3. Замените в файле project/front/src/useAuth.js строку:
```
const API_URL = 'http://localhost:8000/';
```
на строку:
```
const API_URL = import.meta.env.VITE_API_URL;
```

### Копирование проекта на сервер

1. Предположим в первом окне у вас в VS Code открыт каталог var/www облачного сервера.
2. В отдельном окне откройте  редактор VS Code с проектом, размещенным на локальном комрьютере.
3. Переместите мышкой каталог project из одного окна VS Code в другое окно VS Code в каталог www облачного сервера.

### Запуск BackEnd в продакшен

1. Предположим в первом окне у вас в VS Code открыт каталог var/www облачного сервера.
2. Откройте терминал.
3. Перейдите в каталог www/project/back:
```
cd www/project/back
```
4. Активируйте python:
```
sudo apt update
sudo apt install python-is-python3
sudo apt install python3.12-venv
```
5. Создайте, активируйте виртуальное окружение, установите зависимости:
```
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```
6. Пробуем запустить проект в продакшен:
```
uvicorn app.main:app --host 0.0.0.0 --port 8000
```
Здесь 0.0.0.0 разрешает доступ извне
7. Пробно в браузере пробуем открыть документацию:
```
http://84.54.29.221:8000/redoc
```
8. Останавливаем проект CTRL+C.

### Настройка запуска BackEnd в виде сервиса

1. Откройте файловый менеджер в личном кабинете Beget.

2. Создайте файл /etc/systemd/system/back.service с содержимым:
```
[Unit]
Description=FastAPI Backend Service
After=network.target

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=/var/www/project/back
Environment="PATH=/var/www/project/back/.venv/bin"
ExecStart=/var/www/project/back/.venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8000

Restart=always
RestartSec=5
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
```

Пояснения:  
- User и Group — пользователь, от которого запускается сервис (www-data безопасно для веб-сервисов)
- WorkingDirectory — рабочий каталог проекта
- Environment="PATH=..." — виртуальное окружение .venv, чтобы использовать правильный Python и uvicorn
- ExecStart — команда запуска uvicorn
- Restart=always — перезапуск при сбоях
- WantedBy=multi-user.target — чтобы сервис запускался при старте системы

3. Разрешение доступа пользователю www-data:
```
sudo chown -R www-data:www-data /var/www/project
```

4. В терминале VS Code выполните команды запуска сервиса:
```
sudo systemctl daemon-reload
sudo systemctl start back.service
sudo systemctl enable back.service
```
Проверьте статус:
```
sudo systemctl status back.service
```
В случае проблем можно посмотреть log:
```
sudo journalctl -u back.service -f
```
При изменениях в проекте необходимо перезапустить сервис:
```
sudo systemctl restart back.service
```

5. Проверяем в браузере:
```
http://84.54.29.221:8000/redoc
```

### Запуск FrontEnd в продакшен

1. В терминале VS Code переходим в каталог front:
```
cd ../front
```
2. Обновить Node:
```
sudo apt remove nodejs -y
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash
sudo apt install -y nodejs
node -v
```
3. Установка зависимостей:
```
npm install
```
4. Сборка фронтэнда
```
npm run build
```

### Настройка Nginx

1. Необходимо в панели провайдера beget настроить домены:
- для доменов union-ai.ru, www.union-ai.ru прописать A-запись 84.54.29.221
- создать поддомены api.union-ai.ru, www.api.union-ai.ru и прописать в них A-запись 84.54.29.221
- подождать 12-24 часа.

2. Установка Nginx:
```
sudo apt update
sudo apt install software-properties-common -y
sudo add-apt-repository universe
sudo apt update
sudo apt install nginx -y
```

3. Проверка установки:
```
nginx -v
sudo systemctl status nginx
```

4. Создаем файл /etc/nginx/sites-available/back.conf с содержимым:
```
server {
    listen 80;
    server_name api.union-ai.ru;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

5. Создаем файл /etc/nginx/sites-available/front.conf с содержимым:
```
server {
    listen 80;
    server_name union-ai.ru;

    root /var/www/project/front/dist;   # папка с билдом React
    index index.html;

    # Для SPA: все пути перенаправляем на index.html
    location / {
        try_files $uri /index.html;
    }
}
```

6. Включаем конфиги:
```
sudo ln -s /etc/nginx/sites-available/front.conf /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/back.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```


### Подключение домена и выпуск сертификата TLS

1. Установка certbot и плагина для Nginx:
```
sudo apt update
sudo apt install certbot python3-certbot-nginx -y
```

2. Проверка конфигурации Nginx
```
sudo nginx -t
```
Если ошибок нет, перезапускаем Nginx:
```
sudo systemctl restart nginx
```

3. Запуск certbot для домена:

```
sudo certbot --nginx -d union-ai.ru -d api.union-ai.ru
```

В процессе будут вопросы:  
- Подтверждение email для уведомлений: Ваш E-Mail
- Согласие с условиями Let’s Encrypt: Y
- Опция автоматического редиректа HTTP → HTTPS: Y

Certbot проверит, что домен доступен по HTTP, и автоматически:  
- Получит бесплатный сертификат
- Добавит блоки listen 443 ssl в конфиг Nginx
- Настроит редирект с HTTP на HTTPS (по желанию)

4. Файл конфигурации /etc/nginx/sites-available/front.conf автоматически примет вид:
```
server {
    server_name api.union-ai.ru;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/api.union-ai.ru/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/api.union-ai.ru/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}server {
    if ($host = api.union-ai.ru) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    listen 80;
    server_name api.union-ai.ru;
    return 404; # managed by Certbot


}
```

5. Файл конфигурации /etc/nginx/sites-available/front.conf автоматически примет вид:
```
server {
    server_name union-ai.ru;

    root /var/www/project/front/dist;   # папка с билдом React
    index index.html;

    # Для SPA: все пути перенаправляем на index.html
    location / {
        try_files $uri /index.html;
    }

    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/union-ai.ru/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/union-ai.ru/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}server {
    if ($host = union-ai.ru) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    listen 80;
    server_name union-ai.ru;
    return 404; # managed by Certbot


}
```

6. Перезапуск Nginx
```
sudo nginx -t
```
Если ошибок нет, перезапускаем Nginx:
```
sudo systemctl restart nginx
```

7. Проверка в браузере:

Документация:
```
https://api.union-ai.ru/redoc
```

Сайт:
```
https://union-ai.ru
```

## Альтернативное решение

Для пользователей Windows 10 Pro и выше есть возможность установить операционною систему Linux через
встроенную виртуальную машину.
Запуск:
```
WIN+R
wsl
```
В ней можно потренировать делать деплой внтури виртуальной машины Linux.
