#!/bin/bash

# ANSI color--Use these variables to make output in different colors
#  and formats. Color names thta end with 'f' are froreground colors,
#  and those ending with 'b' are background colors.

initializeANSI()
{
    esc="" # If this doesn't work, enter an ESC directly.

    # Foreground colors
    balckf="${esc}[30m";    redf="${esc}[31m";  greenf="{esc}[32m"
    yellowf="${esc}[33m";    bluef="${esc}[34m";  purplef="{esc}[35m"
    cyanf="${esc}[36m";      whitef="{esc}[37m"

    # Background colors
    balckb="${esc}[40m";    redb="${esc}[41m";  greenb="{esc}[42m"
    yellowb="${esc}[43m";    blueb="${esc}[44m";  purpleb="{esc}[45m"
    cyanb="${esc}[46m";      whiteb="{esc}[47m"

    # Bold, italic, underline, and inverse style toggles
    boldon="${esc}[1m";     boldoff="${esc}[22m"
    italicson="${esc}[3m";  italicsoff="${esc}[23m"
    ulon="${esc}[4m";     uloff="${esc}[24m"
    invon="${esc}[7m";  invoff="${esc}[27m"

    reset="${esc}[0m"
}

print_progress(){
    initializeANSI
    echo -e "\n${redf}**${reset} $1 \n"
}