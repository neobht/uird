#!/bin/bash
##
# Thin library around basic I18N facilitated function
#   basic text display, file logging, error display, and prompting
export TEXTDOMAINDIR=$(pwd)/locale

###############################################
##
## Display some text to stderr
## $1 is assumed to be the Message Catalog key
i18n_error() {
        echo "$(gettext -s "$1")" >&2
}

###############################################
##
## Display some text to sdtout
## $1 is assumed to be the Message Catalog key
## rest of args are used as misc information
i18n_display() {
        key="$1"
        shift
        echo -e "$(gettext -s "$key") $@"
}

###############################################
## Append a log message to a file.
## use $1 as target file to append to
## use $2 as catalog key
## rest of args are used as misc information
i18n_fileout() {
        [[ $# -lt 2 ]] && return 1
        file="$1"
        key="$2"
        shift 2
        echo "$(gettext -s "$key") $@" >> ${file}
}

## Prompt the user with a message and echo back the response.
## $1 is assumed to be the Message Catalog key
i18n_prompt() {
        [[ $# -lt 1 ]] && return 1
        read -p "$(gettext "$1"): " rv
        echo $rv
}
