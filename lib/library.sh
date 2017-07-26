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
    balckf="${esc}[40m";    redf="${esc}[41m";  greenf="{esc}[42m"
    yellowf="${esc}[43m";    bluef="${esc}[44m";  purplef="{esc}[45m"
    cyanf="${esc}[46m";      whitef="{esc}[47m"

    # Bold, italic, underline, and inverse style toggles
    boldon="${esc}[1m";     boldoff="${esc}[22m"
    italicson="${esc}[3m";  italicsoff="${esc}[23m"
    ulon="${esc}[4m";     uloff="${esc}[24m"
    invon="${esc}[7m";  invoff="${esc}[27m"

    reset="${esc}[0m"
}