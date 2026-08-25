#!/bin/bash 
# Author: Alexander Betkher <http://magos-linux.ru>

# Если передан аргумент, используем его как имя папки, иначе "dracut"
if [ -n "$1" ]; then
    DIR_NAME="$1"
    FORCE=true
else
    DIR_NAME="dracut"
    FORCE=false
fi

# Определяем рабочий каталог как текущий каталог + имя папки
WORKDIR="$(pwd)/${DIR_NAME}"

# Проверяем, существует ли уже папка
if [ -d "${WORKDIR}" ] ; then
    if [ "$FORCE" = true ]; then
        # Если $1 указан - удаляем без вопросов
        echo "Removing existing ${WORKDIR}..."
        rm -rf "${WORKDIR}"
    else
        # Если $1 не указан - спрашиваем
        echo "${WORKDIR} already exists"
        echo "Enter (a/A) to abort, or another key to continue"
        read qqq
        [ "$qqq" == 'a' -o "$qqq" == "A" ] && exit 1
        rm -rf "${WORKDIR}"
    fi
fi

# Создаем структуру каталогов
mkdir -p "${WORKDIR}/dracut.conf.d" "${WORKDIR}/modules.d"

# Создаем ссылки на файлы dracut
for a in init logger functions ; do
    ln -s /usr/lib/dracut/dracut-${a}.sh ${WORKDIR}/
done

ln -s "$(which dracut-install)" ${WORKDIR}/dracut-install
ln -s "$(which dracut)" ${WORKDIR}/dracut.sh

# Создаем ссылки на модули
ln -s ${WORKDIR}/../modules.d/* "${WORKDIR}/modules.d/" 2>/dev/null || true
ln -s /usr/lib/dracut/modules.d/* "${WORKDIR}/modules.d/"
