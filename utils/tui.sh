#!/bin/bash

# BASH-Ops: A Lightweight TUI Library using ANSI Escape Codes
#
# This library provides a set of pure-bash functions for creating Terminal
# User Interfaces without external dependencies like ncurses. It works by
# printing raw ANSI escape codes to stdout.

# --- Colors and Styles --- #
C_RESET='\e[0m'
C_BOLD='\e[1m'

C_BLACK='\e[30m'
C_RED='\e[31m'
C_GREEN='\e[32m'
C_YELLOW='\e[33m'
C_BLUE='\e[34m'
C_MAGENTA='\e[35m'
C_CYAN='\e[36m'
C_WHITE='\e[37m'
C_GREY='\e[90m'

# --- Terminal Control --- #

# Initializes the TUI environment.
# Saves the screen state and hides the cursor.
tui_init() {
    tput smcup # Save screen
    tput civis # Hide cursor
}

# Restores the terminal to its original state.
# Restores the screen and shows the cursor.
tui_cleanup() {
    tput rmcup # Restore screen
    tput cnorm # Show cursor
}

# Clears the entire terminal screen.
tui_clear_screen() {
    printf "\e[2J"
}

# Moves the cursor to a specific row and column.
# @param $1 - row The row number (1-based).
# @param $2 - col The column number (1-based).
tui_move_cursor() {
    printf "\e[${1};${2}H"
}

# --- Drawing Functions --- #

# Draws a box with borders and an optional title.
# @param $1 - row    The top row of the box.
# @param $2 - col    The left column of the box.
# @param $3 - width  The total width of the box.
# @param $4 - height The total height of the box.
# @param $5 - title  An optional title to display at the top.
tui_draw_box() {
    local row=$1 col=$2 width=$3 height=$4 title=$5
    local end_col=$((col + width - 1))
    local end_row=$((row + height - 1))

    # Draw corners
    tui_move_cursor $row $col; printf "┌"
    tui_move_cursor $row $end_col; printf "┐"
    tui_move_cursor $end_row $col; printf "└"
    tui_move_cursor $end_row $end_col; printf "┘"

    # Draw horizontal lines
    for i in $(seq $((col + 1)) $((end_col - 1))); do
        tui_move_cursor $row $i; printf "─"
        tui_move_cursor $end_row $i; printf "─"
    done

    # Draw vertical lines
    for i in $(seq $((row + 1)) $((end_row - 1))); do
        tui_move_cursor $i $col; printf "│"
        tui_move_cursor $i $end_col; printf "│"
    done

    # Draw title
    if [[ -n "$title" ]]; then
        tui_move_cursor $row $((col + 2))
        printf "${C_BOLD}${C_WHITE} %s ${C_RESET}" "$title"
    fi
}

# Writes text at a specific position.
# @param $1 - row  The row to write on.
# @param $2 - col  The column to start writing at.
# @param $3 - text The text to write.
tui_write_text() {
    local row=$1 col=$2 text=$3
    tui_move_cursor $row $col
    printf "$text"
}