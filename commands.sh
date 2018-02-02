#!/usr/bin/env bash
# darybot ~ Subroutines/Commands
# Copyright (c) 2017 David Kim
# This program is licensed under the "MIT License".
# Date of inception: 11/21/17

read nick chan msg      # Assign the 3 arguments to nick, chan and msg.

IFS=''                  # internal field separator; variable which defines the char(s)
                        # used to separate a pattern into tokens for some operations
                        # (i.e. space, tab, newline)

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BOT_NICK="$(grep -P "BOT_NICK=.*" ${DIR}/darybot.sh | cut -d '=' -f 2- | tr -d '"')"

if [ "${chan}" = "${BOT_NICK}" ] ; then chan="${nick}" ; fi

###################################################  Settings  ####################################################

AUTHORIZED='_sharp MattDaemon'

###############################################  Subroutines Begin  ###############################################

function has { $(echo "${1}" | grep -P "${2}" > /dev/null) ; }

function say { echo "PRIVMSG ${1} :${2}" ; }

function send {
    while read -r line; do                          # -r flag prevents backslash chars from acting as escape chars.
      currdate=$(date +%s%N)                         # Get the current date in nanoseconds (UNIX/POSIX/epoch time) since 1970-01-01 00:00:00 UTC (UNIX epoch).
      if [ "${prevdate}" -gt "${currdate}" ] ; then  # If 0.5 seconds hasn't elapsed since the last loop iteration, sleep. (i.e. force 0.5 sec send intervals).
        sleep $(bc -l <<< "(${prevdate} - ${currdate}) / ${nanos}")
        currdate=$(date +%s%N)
      fi
      prevdate=${currdate}+${interval}
      echo "-> ${1}"
      echo "${line}" >> ${BOT_NICK}.io
    done <<< "${1}"
}

# This subroutine looks up definitions in Google.

function googleSubroutine {
    payload="${1}"

    python google.py "${payload}" > output.tmp

    if [ -s output.tmp ] ; then
        while read -r line ; do                                 # -r flag prevents backslash chars from acting as escape chars.
            say ${chan} "${line}"
        done < output.tmp
    else
        say ${chan} "Try googling something else.."
    fi
}

# This subroutine displays documentation for darybot's functionalities.

function helpSubroutine {
    say ${chan} "usage: !google [anything] | !define [whatever]"
}

################################################  Subroutines End  ################################################

# Ω≈ç√∫˜µ≤≥÷åß∂ƒ©˙∆˚¬…ææœ∑´®†¥¨ˆøπ“‘¡™£¢∞••¶•ªº–≠«‘“«`
# ─━│┃┄┅┆┇┈┉┊┋┌┍┎┏┐┑┒┓└┕┖┗┘┙┚┛├┝┞┟┠┡┢┣┤┥┦┧┨┩┪┫┬┭┮┯┰┱┲┳┴┵┶┷┸┹┺┻┼┽┾┿╀╁╂╃╄╅╆╇╈╉╊╋╌╍╎╏
# ═║╒╓╔╕╖╗╘╙╚╛╜╝╞╟╠╡╢╣╤╥╦╧╨╩╪╫╬╭╮╯╰╱╲╳╴╵╶╷╸╹╺╻╼╽╾╿

################################################  Commands Begin  #################################################

# Help Command.

if has "${msg}" "^!darybot$" || has "${msg}" "^darybot: help$" || has "${msg}" "^!google$" || has "${msg}" "^darybot: google$" || has "${msg}" "^darybot: google$" ; then
    helpSubroutine

# Alive.

elif has "${msg}" "^!alive(\?)?$" || has "${msg}" "^darybot: alive(\?)?$" ; then
    str1='running! '
    str2=$(ps aux | grep ./darybot | head -n 1 | awk '{ print "[%CPU "$3"]", "[%MEM "$4"]", "[START "$9"]", "[TIME "$10"]" }')
    str="${str1}${str2}"
    say ${chan} "${str}"

# Source.

elif has "${msg}" "^darybot: source$" ||
     has "${msg}" "^!darybot source$" ||
     has "${msg}" "^!print source$" ; then
    say ${chan} "Try -> https://github.com/kimdj/darybot, /u/dkim/darybot"

# Google.

elif has "${msg}" "^!google " ; then
    payload=$(echo ${msg} | sed -r 's/^!google //')
    googleSubroutine "${payload}"

elif has "${msg}" "^!define " ; then
    payload=$(echo ${msg} | sed -r 's/^!define //')
    googleSubroutine "${payload}"

# Have darybot send an IRC command to the IRC server.

elif has "${msg}" "^darybot: injectcmd " && [[ "${AUTHORIZED}" == *"${nick}"* ]] ; then
    cmd=$(echo ${msg} | sed -r 's/^darybot: injectcmd //')
    send "${cmd}"

# Have darybot send a message.

elif has "${msg}" "^darybot: sendcmd " && [[ "${AUTHORIZED}" == *"${nick}"* ]] ; then
    buffer=$(echo ${msg} | sed -re 's/^darybot: sendcmd //')
    dest=$(echo ${buffer} | sed -e "s| .*||")
    message=$(echo ${buffer} | cut -d " " -f2-)
    say ${dest} "${message}"

fi

#################################################  Commands End  ##################################################
