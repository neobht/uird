#!/bin/bash
# Author: Alexander Betkher <http://magos-linux.ru>
# Author: Deep..., мать его, ...seek


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
        echo "Removing existing ${WORKDIR}..."
        rm -rf "${WORKDIR}"
    else
        echo "${WORKDIR} already exists"
        echo "Enter (a/A) to abort, or another key to continue"
        read qqq
        [ "$qqq" == 'a' -o "$qqq" == "A" ] && exit 1
        rm -rf "${WORKDIR}"
    fi
fi

# Создаем структуру каталогов
mkdir -p "${WORKDIR}/dracut.conf.d" "${WORKDIR}/modules.d"

# Определяем режим создания ссылок
USE_RELATIVE="${USE_RELATIVE:-false}"

case "$USE_RELATIVE" in
    'yes'|'true'|'on'|'1')
        USE_RELATIVE='yes'
        ;;
    *)
        USE_RELATIVE='no'
        ;;
esac

# Функция для создания ссылок с realpath
create_link() {
    local target="$1"
    local link_dir="$2"
    
    if [ "$USE_RELATIVE" = 'yes' ]; then
        # Вычисляем относительный путь с помощью realpath
        local relative_path=$(realpath --relative-to="$link_dir" "$target" 2>/dev/null)
        ln -s "$relative_path" "${link_dir}/"
    else
        ln -s "$target" "${link_dir}/"
    fi
}

# Создаем ссылки на файлы dracut
for a in init logger functions ; do
    create_link "/usr/lib/dracut/dracut-${a}.sh" "${WORKDIR}"
done

create_link "$(which dracut-install)" "${WORKDIR}"
create_link "$(which dracut)" "${WORKDIR}"

# Создаем ссылки на модули
# Сначала системные модули
for module in /usr/lib/dracut/modules.d/*; do
    [ -e "$module" ] && create_link "$module" "${WORKDIR}/modules.d/"
done

# Затем локальные модули (переопределяют системные при совпадении имен)
for module in ${WORKDIR}/../modules.d/*; do
    [ -e "$module" ] && create_link "$module" "${WORKDIR}/modules.d/"
done 2>/dev/null || true

echo "Done! Links created in ${WORKDIR}"
echo "Link mode: $([ "$USE_RELATIVE" = 'yes' ] && echo "RELATIVE" || echo "ABSOLUTE")"
