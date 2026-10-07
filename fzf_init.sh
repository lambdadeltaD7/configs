#!/bin/bash

source <(fzf --zsh)

export FZF_DEFAULT_OPTS="
  --layout=reverse
  --border=rounded
  --prompt='❯ '
  --pointer='▶ '
  --marker='✓'
  --info=inline
"

export FZF_CTRL_R_OPTS="
  --style 'minimal'
  --margin=1
  --color 'prompt:#00bbbb'
  --color 'bg+:#003333' # bg curr_line
  --color 'fg:#ffffff'  # text
  --color 'fg+:#ffffff' # text curr_line
  --color 'hl:#00dd00'  # highlighted
  --color 'hl+:#00ee00' # highlighted curr_line
  --color 'pointer:#00bbbb'
  --color 'border:#00bbbb'
"
