### Базовое описание основных принципов

Поддерживаемые расширения в MagOS Linux по умолчанию:

    *.ROM - RO слой
    *.RWM - RW слой
    *.XZM - RO слой с squashfs 
    *.XZM.CP - распаковывается в корень системы

    *.RWM.ENC - RW слой криптованый
    *.ROM.ENC - RO слой криптованый

### Параметры командной строки

Ввиду множественности параметров ядра введен префикс параметров '**uird**'  (Unified Init Ram Disk): 

    uird.basecfg=              - расположение базового конфигурационного файла basecfg.ini
    uird.config=               - расположение конфигурационного файла системы MagOS.ini
    uird.sgnfiles[+]=          - перечисление файлов-маркеров для поиска источников указанных в uird.from= в соответсвии с их порядком перечисления
    uird.ro[+]=                - фильтр для модулей/директорий, которые монтируются в режиме RO
    uird.rw[+]=                - фильтр для модулей/директорий, которые монтируются в режиме RW
    uird.cp[+]=                - фильтр для модулей/директорий, содержимое которых копируется в корень
    uird.copy2ram[+]=          - фильтр для модулей/директорий, которые копируются в RAM
    uird.copy2cache[+]=        - фильтр для модулей/директорий, которые копируются в КЭШ
    uird.ramsize=              - размер RAM
    uird.ip=                   - IP:GW:MASK , если не указан, то используется DHCP
    uird.netfsopt[+]=          - дополнительные опции монтирования сетевых ФС: sshfs,nfs,curlftpfs,cifs
    uird.load[+]=              - фильтр для модулей/директорий, которые необходимо подключить на этапе загрузки
    uird.noload[+]=            - фильтр для модулей/директорий, которые необходимо пропустить во время загрузки
    uird.from[+]=              - источники, где лежат модули/директории для системы
    uird.cache[+]=             - источники, в которые стоит синхронизировать модули/директории 
    uird.homes[+]=             - источники, где хранятся домашние директории пользователей (объединяются AUFS) 
    uird.home=                 - источник, где хранятся домашние директории пользователей 
    uird.changes=              - источник, где хранить персистентные изменения
    uird.mounts=               - источники , которые будут смонтированы в указанные точки монтирования
    uird.find_params[+]=       - параметры для утилиты find при поиске модулей (например: -maxdepth,2)
    uird.help                  - печатает подсказку по параметрам UIRD
    uird.break=STAGE           - остановка загрузки на стадии STAGE и включение режима отладки (debug) 
    uird.mode=MODE             - режим работы сохраниениями (clean, clear, changes, machines)
    uird.scan=                 - поиск установленных OC и компонентов для определения параметров uird
    uird.swap=                 - список SWAP разделов и/или файлов для подключения, разделитель в списке ";" или ","
    uird.syscp[+]=             - список файлов (каталогов) для копирования из UIRD в систему /путь/файл::/путь/каталог 


В качестве значений параметров могут быть использованы команды shell:

    uird.from="/MagOS;$( eval [ $(date +%u) -gt 5 ] && echo /MagOS-Data)" - подключать MagOS-Data только по выходным
    uird.changes="$(mkdir -p /MagOS-Data/changes && echo /MagOS-Data/changes)" 

Для более подробного описания параметров смотрите встроенную [подсказку](https://github.com/neobht/uird/tree/master/initrd/usr/share/uird.help)

### Уровни для источников

Вводится базовый уровень layer-base и соответствующий параметр uird.from=:

    uird.from=/MagOS;/MagOS-Data;MagOS.iso;http://magos.sibsau.ru/repository/netlive/2014.64/MagOS

Вводится уровень кеша layer-cache и соответствующий параметр uird.cache=. Служит для синхронизации удаленных репозиториев в локальные или частные (INTRANET) репозитории, а также для обновления системы.

    uird.cache=/MagOS/cache;/MagOS-Data/cache;/MagOS-Data/netlive

Вводится уровень домашних директорий пользователя layer-homes и соответствующие параметры: uird.homes=, uird.home=:

    uird.homes=/MagOS-Data/homes;/MagOS-Data/home.img;nfs://magos.sibsau.ru/homes/n/e/neobht
    uird.home=/MagOS-Data/home

Все директории пользователя из различных источников каскадно-объединяются посредством AUFS и монтируются в /home. Более приоритетным является самый первый источник, затем в порядке перечисления уменьшается приоритет.
В случае, если источник задан параметром uird.home=, то происходит монтирование источника в /home.

Вводится уровень точек монтирования layer-mounts и соответствующий параметр uird.mounts=:

    uird.mounts=/MagOS/www::/var/www;http://magos.sibsau.ru/repository/netlive/2014.64/MagOS::/mnt/http


### Типы источников

*     **/path/dir**                 - директория на любом доступном носителе
*     **/dev/[..]/path/dir**        - директория на заданном носителе
*     **LABEL@/path/dir**           - директория на носителе с меткой LABEL
*     **UUID@/path/dir**            - директория на носителе с uuid UUID
*     **file-dvd.iso, file.img**    - образ диска (ISO, образ блочного устройства)
*     **http://server/path/...**    - источник доступный по HTTP (используется httpfs) 
*     **ssh://server/path/...**     - источник доступный по SSH (используется sshfs)
*     **ftp://server/path/...**     - источник доступный по FTP (используется curlftpfs)
*     **nfs://server/path/...**     - источник доступный по NFS 
*     **cifs://server/path/...**    - источник доступный по CIFS 

### Порядок инициализации системы

1. Осуществляется поиск конфигурационного файла по пути, указанному в параметре uird.basecfg=
2. Устанавливаются параметры из конфигурационного файла, которые еще не установлены в параметрах ядра
3. Происходит монтирование источников **base**-уровня в порядке, указанном в параметре uird.from= 
4. Происходит монтирование источников **cache**-уровня в порядке, указанном в параметре uird.cache= 
5. Происходит монтирование источников **homes**-уровня в порядке, указанном в параметре uird.homes= 
6. Происходит подключение в самый _верхний_ уровень AUFS источника персистентных изменений, указанного в параметре uird.changes=
7. Осуществляется синхронизация base-уровня в cache-уровень с учетом параметра uird.copy2cache=, а также соответствия подуровней. Если подуровней cache-уровня меньше, чем base-уровня, то оставшиеся подуровни синхронизируются в RAM.


            ├── layer-base       ==>      ├── layer-cache
            │   ├── 0            -->      │   ├── 0
            │   ├── 1            -->      │   ├── 1
            │   ├── ...          -->      │   └── ...
            │   └── ...          -->      │   RAM


8. Осуществляется синхронизация base,cache-уровней в RAM с учетом параметра uird.copy2ram=
9. Осуществляется монтирование источников **mounts**-уровня в порядке, указанном в параметре uird.mounts=
10. Осуществляется поиск модулей/директорий в RAM, cache-уровне, base-уровне и подключение их на _[верхний-1]_ уровень AUFS или копирование в корень (с учетом фильтров, указанных в параметрах uird.load=, uird.noload=,uird.ro=,uird.rw=,uird.cp=) со следующим приоритетом: 


                           uird.load --> uird.noload
                           uird.cp --> uird.rw --> uird.ro


11. Осуществляется каскадное объединение источников homes-уровня и подключение их в /home
12. Выполняются скрипты rc.preinit

### Структура конфигурационного файла basecfg.ini по умолчанию

      uird.config=MagOS.ini
      uird.ramsize=70%
      uird.ro=*.xzm;*.rom;*.rom.enc;*.pfs
      uird.rw=*.rwm;*.rwm.enc
      uird.cp=*.xzm.cp,*/rootcopy
      uird.load=/base/,/modules/,rootcopy
      uird.noload=/MagOS-Data/changes,/MagOS-Data/homes
      uird.from=/MagOS;/MagOS-Data
      uird.find_params=-maxdepth_3
      uird.mode=clean 
      uird.changes=/MagOS-Data/changes
      uird.syscp=/livekitlib::/usr/lib/magos/scripts;/uird.scan::/usr/lib/magos/scripts;/liblinuxlive::/mnt/live/liblinuxlive
    
!!! Если параметр uird.basecfg= не задан, то используется /uird_configs/basecfg.ini внутри initrd.

### Структура системной директории 

      /memory/
      ├── bundles                   - точка монтирования модулей
      │   ├── 00-kernel.xzm
      │   ├── 01-firmware.xzm
      │   ├── 10-core.xzm
      │   ├── 80-eepm-1.5.2.xzm
      │   └── ...                   - и т.д.
      ├── changes                   - точка монтирования для хранения изменений 
      │   ├── etc
      │   ├── home
      │   ├── memory
      │   ├── run
      │   ├── var
      │   └── ...                   - и т.д.
      ├── data                      - точка монтирования источников
      │   ├── cache                     - кеш уровня
      │   ├── homes                     - homes уровня
      │   ├── mounts                    - mounts уровня
      │   ├── machines                  - машинно-зависимых изменений
      │   └── from                      - базового уровня
      ├── copy2ram                  - точка монтирования для синхронизации модулей/директорий в ОЗУ
      ├── layer-base                - точка монтирования базового уровня
      │   ├── 0                         - ресурс первого источника
      │   ├── 1                         - ресурс второго источника (в порядке перечисления в uird.from=)
      │   └── ...                       - и т.д.
      ├── layer-cache               - точка монтирования кеш уровня
      │   ├── 0                         - ресурс первого источника
      │   ├── 1                         - ресурс второго источника (в порядке перечисления в uird.cache=)
      │   └── ...                       - и т.д.
      ├── layer-homes               - точка монтирования homes уровня
      │   ├── 0                         - ресурс первого источника
      │   ├── 1                         - ресурс второго источника (в порядке перечисления в uird.homes=)
      │   └── ...                       - и т.д.
      ├── layer-mounts               - точка монтирования mounts уровня
      │   ├── 0                         - ресурс первого источника
      │   ├── 1                         - ресурс второго источника (в порядке перечисления в uird.mounts=)
      │   └── ...                       - и т.д.
      ├── cmdline                   - системный файл для хранения дополнительных параметров командной строки
      └── MagOS.ini.gz              - системный файл для хранения конфигурационного файла


### Реализация

В основе реализации лежит набор скриптов инициализации dracut (модули base, kernel-modules ) и скрипты uird (livekitlib+uird-init).

    cmdline-hook: parse-root-uird.sh (проверяет параметр root=uird)
    mount-hook: mount-uird.sh (выполняет скрипт uird-init)

* [livekitlib](https://github.com/neobht/uird/blob/master/modules.d/00uird/livekit/livekitlib) - содержит библиотеку функций системы инициализации.
* [uird-init](https://github.com/neobht/uird/blob/master/modules.d/00uird/livekit/uird-init) - последовательно выполняет набор функций из livekitlib и осуществляет каскадно-блочное монтирование модулей системы в единый корень AUFS в директорию указанную в переменной dracut $NEWROOT.

