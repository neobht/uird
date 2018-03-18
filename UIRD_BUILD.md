## 1. Клонируем репозиторий.
  * uird clone --recursive https://github.com/neobht/uird.git
## 2. Устанавливаем зависисмости необходимые для сборки dracut. Проще всего установить src пакет dracut для вашего дистрибутива.
# Приблизительный список:
  * make
  * pkg-config
  * kmod
  * gcc
  * glibc
  * linux-api-headers
## 3. Собираем бизибокс
  * cd ./uird
  * ./make_busybox.sh
## 4. Собираем дракут
  * ./make_dracut.sh
# Ищем подходящий конфиг в uird/configs/uird_configs
# Если не нашли пишете свой.
## Собираем UIRD
  * ./mkuird ИМЯ_КОНФИГА
## Например:
  * ./mkuird MagOS
