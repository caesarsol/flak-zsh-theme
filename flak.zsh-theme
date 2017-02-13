# oh-my-zsh Flak Theme
# by caesarsol <cesare.soldini@gmail.com>

### Colors

# see documentation at http://linux.die.net/man/1/zshexpn
# A: finds the absolute path, even if this is symlinked
# h: dirname
THIS_DIR="${0:A:h}"
source "$THIS_DIR/flak.colors.zsh"

### Git

flak_git_status() {
  local STATUS
  STATUS="$(git status --branch --short --porcelain 2>/dev/null)"
  local -a FILES_STATUS
  FILES_STATUS=( $(echo "$STATUS" | egrep -o '^[MARCDU\? ][MARCDU\? ]' | tr ' ' '-' ) )
  local SYNC_STATUS
  SYNC_STATUS="$(echo "$STATUS" | grep -oE '^## ')"
  local BRANCH
  BRANCH="$(echo "$STATUS" | grep '##' | grep -oE '[a-z/]+' | head -n1)"

  local N_MODIFIED=0
  local N_ADDED=0
  local N_DELETED=0
  local N_UNSTAGED=0
  local N_UNMERGED=0
  local N_UNTRACKED=0

  # STAGED  WORKTREE   Meaning
  # ---------------------------------------------------
  #             [MD]   not updated
  # M          [ MD]   updated in index
  # A          [ MD]   added to index
  # R          [ MD]   renamed in index
  # C          [ MD]   copied in index
  # D           [ M]   deleted from index
  # [MARC]             index and work tree matches
  # [ MARC]       M    work tree changed since index
  # [ MARC]       D    deleted in work tree
  # -------------------------------------------------

  for ST in ${FILES_STATUS[@]}; do
    #echo -n $ST
    [[ $ST =~ [MRC].   ]] && (( N_MODIFIED ++ ))
    [[ $ST =~ A.       ]] && (( N_ADDED    ++ ))
    [[ $ST =~ D.       ]] && (( N_DELETED  ++ ))
    [[ $ST =~ .[MARCD] ]] && (( N_UNSTAGED ++ ))
    [[ $ST =~ UU       ]] && (( N_UNMERGED ++ ))
    [[ $ST = '??'      ]] && (( N_UNTRACKED++ ))
  done

  # case "$SYNC_STATUS" in
  #   *...*) ;;
  # esac

  (( N_ADDED     > 0 )) && rgbecho 040 "A$N_ADDED"
  (( N_MODIFIED  > 0 )) && rgbecho 020 "M$N_MODIFIED"
  (( N_DELETED   > 0 )) && rgbecho 510 "D$N_DELETED"
  (( N_UNSTAGED  > 0 )) && rgbecho 545 "US$N_UNSTAGED"
  (( N_UNMERGED  > 0 )) && rgbecho 512 "UM$N_UNMERGED"
  (( N_UNTRACKED > 0 )) && rgbecho 515 "UT$N_UNTRACKED"
  rgbecho 000
}

flak_git_branch () {
  REF=$(git symbolic-ref HEAD 2> /dev/null) || \
  REF=$(git rev-parse --short HEAD 2> /dev/null) || return
  echo -n "${REF#refs/heads/}"
}

fill_space () {
  local STR="$1$2"
  local ZERO='%([BSUbfksu]|([FB]|){*})'
  local LENGTH=${#${(S%%)STR//$~ZERO/}}
  local SPACES=""
  (( LENGTH = ${COLUMNS} - $LENGTH - 1 ))

  for i in {0..$LENGTH}; do
    SPACES="$SPACES "
  done

  echo -n $SPACES
}

millis() { # milliseconds since EPOCH 0
  date +%s%3N
}

mtime() {
  local B=$(millis)
  $* > /dev/null
  local E=$(millis)
  echo $(( E - B ))
}

flak_left_prompt() {
  greybgecho 3
  rgbecho 555 "["
  rgbecho 550 "%*" # %* - time HH:MM:SS
  rgbecho 555 "]"
  rgbecho 555 " "
  rgbecho 005 "%n" # %n - username
  rgbecho 555 "@"
  rgbecho 045 "%m" # %m - machine name
  rgbecho 555 ":"
  rgbecho 030 "%~" # %~ - current path
  rgbecho 555
}

flak_right_prompt() {
  rgbecho 555 "$(flak_git_branch)"
  rgbecho 555 " "
  rgbecho 555 "$(git_remote_status)"
  rgbecho 555 " "
  rgbecho 555 "$(flak_git_status)"
  rgbecho 555 " "
  rgbecho 203 "$(nvm_prompt_info)"
  rgbecho 555 " "
  rgbecho 510 "$(ruby_prompt_info)"
  rgbecho 555 " "
  greybgecho 0
}

flak_build_prompt() {
  LEFT=$(flak_left_prompt)
  if (( COLUMNS > 100 )); then
    RIGHT=$(flak_right_prompt)
    echo -n "$LEFT"
    fill_space "$RIGHT" "$LEFT"
    echo -n "$RIGHT"
  #elif (( COLUMNS < 50 )); then
  else
    echo -n "$LEFT"
    fill_space "$LEFT"
  fi
}

benchmark() {
  echo "flak_build_prompt:           ms $(mtime flak_build_prompt)"
  echo "                           ==="
  echo " '- flak_git_status:    ms $(mtime flak_git_status)"
  echo " '- flak_git_branch:    ms $(mtime flak_git_branch)"
  echo " '- flak_rbenv_version: ms $(mtime flak_rbenv_version)"
}

setopt prompt_subst

PROMPT='
$(flak_build_prompt)
$(rgb 050)%# %{$reset_color%}'

ZSH_THEME_GIT_PROMPT_EQUAL_REMOTE="%{$fg[green]%}="
ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE="%{$fg[blue]%}^"
ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE="%{$fg[red]%}v"
ZSH_THEME_GIT_PROMPT_DIVERGED_REMOTE="$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE"
