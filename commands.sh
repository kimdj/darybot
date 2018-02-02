#!/usr/bin/env bash
# lprbot ~ Subroutines/Commands
# Copyright (c) 2017 David Kim
# This program is licensed under the "MIT License".
# Date of inception: 11/21/17

read nick chan msg      # Assign the 3 arguments to nick, chan and msg.

IFS=''                  # internal field separator; variable which defines the char(s)
                        # used to separate a pattern into tokens for some operations
                        # (i.e. space, tab, newline)

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BOT_NICK="$(grep -P "BOT_NICK=.*" ${DIR}/lprbot.sh | cut -d '=' -f 2- | tr -d '"')"

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

# This subroutine executes the print script.

function printSubroutine {
    if [ "$#" -eq 0 ] ; then

        say ${chan} "$(ssh -oConnectTimeout=4 stargate /u/dkim/sandbox/scripts/printer-script.sh -u ${nick})"

    else

        str="$@"
        IFS=' '                          # space is set as delimiter
        read -ra arr <<< "${str}"        # str is read into an array as tokens separated by IFS
        for arg in "${arr[@]}"; do       # access each element of array
            case "${arg}" in
                fab)
                    say ${chan} "$(ssh -oConnectTimeout=4 stargate /u/dkim/sandbox/scripts/printer-script.sh -u ${nick} fab8201bw1)"
                    say ${chan} "$(ssh -oConnectTimeout=4 stargate /u/dkim/sandbox/scripts/printer-script.sh -u ${nick} fabc8802bw1)"
                    say ${chan} "$(ssh -oConnectTimeout=4 stargate /u/dkim/sandbox/scripts/printer-script.sh -u ${nick} fab6001bw1)"
                    say ${chan} "$(ssh -oConnectTimeout=4 stargate /u/dkim/sandbox/scripts/printer-script.sh -u ${nick} fab5517bw1)"
                    say ${chan} "$(ssh -oConnectTimeout=4 stargate /u/dkim/sandbox/scripts/printer-script.sh -u ${nick} fab5517bw2)"
                    say ${chan} "$(ssh -oConnectTimeout=4 stargate /u/dkim/sandbox/scripts/printer-script.sh -u ${nick} fab5517clr1)"
                    say ${chan} "$(ssh -oConnectTimeout=4 stargate /u/dkim/sandbox/scripts/printer-script.sh -u ${nick} fab25bw1)"
                    ;;
                eb)
                    say ${chan} "$(ssh -oConnectTimeout=4 stargate /u/dkim/sandbox/scripts/printer-script.sh -u ${nick} eb325bw1)"
                    say ${chan} "$(ssh -oConnectTimeout=4 stargate /u/dkim/sandbox/scripts/printer-script.sh -u ${nick} eb325bw2)"
                    say ${chan} "$(ssh -oConnectTimeout=4 stargate /u/dkim/sandbox/scripts/printer-script.sh -u ${nick} eb325clr1)"
                    say ${chan} "$(ssh -oConnectTimeout=4 stargate /u/dkim/sandbox/scripts/printer-script.sh -u ${nick} eb420bw1)"
                    say ${chan} "$(ssh -oConnectTimeout=4 stargate /u/dkim/sandbox/scripts/printer-script.sh -u ${nick} eb420clr1)"
                    ;;
                *)
                    if [[ "${arg}" == "fab8201bw1" ]] ||
                       [[ "${arg}" == "fabc8802bw1" ]] ||
                       [[ "${arg}" == "fab6001bw1" ]] ||
                       [[ "${arg}" == "fab5517bw1" ]] ||
                       [[ "${arg}" == "fab5517bw2" ]] ||
                       [[ "${arg}" == "fab5517clr1" ]] ||
                       [[ "${arg}" == "fab25bw1" ]] ||
                       [[ "${arg}" == "eb325bw1" ]] ||
                       [[ "${arg}" == "eb325bw2" ]] ||
                       [[ "${arg}" == "eb325clr1" ]] ||
                       [[ "${arg}" == "eb420bw1" ]] ||
                       [[ "${arg}" == "eb420clr1" ]] ; then
                        say ${chan} "$(ssh -oConnectTimeout=4 stargate /u/dkim/sandbox/scripts/printer-script.sh -u ${nick} ${arg})"
                    else
                        say ${chan} "${arg} not found"
                    fi
                    ;;
            esac
        done
    fi
}

# This subroutine displays documentation for lprbot's functionalities.

function helpSubroutine {
    say ${chan} "usage: !print [all] [fab | eb] [fab8802bw1 eb325bw1 ...] [list] [jobs] [source]"
}

# List all the printers.

function listSubroutine {
    for printer in "-----------------------------------------------" "fab5517bw1    (Intel Lab/FAB MCECS General Lab)" "fab5517bw2    (Intel Lab/FAB MCECS General Lab)" "fab5517clr1   (Intel Lab/FAB MCECS General Lab)" "fab6001bw1    (Tektronix Lab)" "fab8201bw1    (Doghaus)" "fabc8802bw1   (Linux Lab)" "fab25bw1      (Power Lab)" "eb325bw1      (MCECS General Lab, West)" "eb325bw2      (MCECS General Lab, East)" "eb325clr1     (MCECS General Lab, West)" "eb420bw1      (MCAE Lab)" "eb420clr1     (MCAE Lab)" ; do
        say ${nick} ${printer}
    done
}

# List all printer jobs.

function jobsSubroutine {
    for printer in "fab8201bw1" "fabc8802bw1" "fab6001bw1" "fab5517bw1" "fab5517bw2" "fab5517clr1" "fab25bw1" "eb325bw1" "eb325bw2" "eb325clr1" "eb420bw1" "eb420clr1" ; do
        lpq -P "${printer}" > "${DIR}/jobs/${printer}.status"
    done

    FILES=${DIR}/jobs/*
    say ${nick} "-----------------------------------------------"
    for f in ${FILES} ; do
        while read line ; do
            say ${nick} "${line}"
        done < ${f}
    done

}

################################################  Subroutines End  ################################################

# Ω≈ç√∫˜µ≤≥÷åß∂ƒ©˙∆˚¬…ææœ∑´®†¥¨ˆøπ“‘¡™£¢∞••¶•ªº–≠«‘“«`
# ─━│┃┄┅┆┇┈┉┊┋┌┍┎┏┐┑┒┓└┕┖┗┘┙┚┛├┝┞┟┠┡┢┣┤┥┦┧┨┩┪┫┬┭┮┯┰┱┲┳┴┵┶┷┸┹┺┻┼┽┾┿╀╁╂╃╄╅╆╇╈╉╊╋╌╍╎╏
# ═║╒╓╔╕╖╗╘╙╚╛╜╝╞╟╠╡╢╣╤╥╦╧╨╩╪╫╬╭╮╯╰╱╲╳╴╵╶╷╸╹╺╻╼╽╾╿

################################################  Commands Begin  #################################################

# Help Command.

if has "${msg}" "^!lprbot$" || has "${msg}" "^lprbot: help$" || has "${msg}" "^!print$" || has "${msg}" "^lprbot: print$" || has "${msg}" "^lprbot: print$" || has "${msg}" "^!print help$" ; then
    helpSubroutine

# Alive.

elif has "${msg}" "^!alive(\?)?$" || has "${msg}" "^lprbot: alive(\?)?$" ; then
    str1='running! '
    str2=$(ps aux | grep ./lprbot | head -n 1 | awk '{ print "[%CPU "$3"]", "[%MEM "$4"]", "[START "$9"]", "[TIME "$10"]" }')
    str="${str1}${str2}"
    say ${chan} "${str}"

# Source.

elif has "${msg}" "^lprbot: source$" ||
     has "${msg}" "^!lprbot source$" ||
     has "${msg}" "^!print source$" ; then
    say ${chan} "Try -> https://github.com/kimdj/lprbot, /u/dkim/lprbot"

# Print script.

elif has "${msg}" "^!print all$" || has "${msg}" "^lprbot: print all$" ; then
    printSubroutine

elif has "${msg}" "^!print list$" ||
     has "${msg}" "^lprbot: print list$" ||
     has "${msg}" "^lprbot: list$" ; then
    listSubroutine

elif has "${msg}" "^!print jobs$" || has "${msg}" "^lprbot: jobs$" ; then
    jobsSubroutine

elif has "${msg}" "^!print override" ; then
    true

elif has "${msg}" "^!print " || has "${msg}" "^lprbot: print " ; then
    arg=$(echo ${msg} | sed -r 's/^!print //')                # cut out the leading part from ${msg}
    arg=$(echo ${arg} | sed -r 's/^lprbot: print //')         # cut out the leading part from ${msg}

    printSubroutine ${arg}

# Have lprbot send an IRC command to the IRC server.

elif has "${msg}" "^lprbot: injectcmd " && [[ "${AUTHORIZED}" == *"${nick}"* ]] ; then
    cmd=$(echo ${msg} | sed -r 's/^lprbot: injectcmd //')
    send "${cmd}"

# Have lprbot send a message.

elif has "${msg}" "^lprbot: sendcmd " && [[ "${AUTHORIZED}" == *"${nick}"* ]] ; then
    buffer=$(echo ${msg} | sed -re 's/^lprbot: sendcmd //')
    dest=$(echo ${buffer} | sed -e "s| .*||")
    message=$(echo ${buffer} | cut -d " " -f2-)
    say ${dest} "${message}"

fi

#################################################  Commands End  ##################################################
