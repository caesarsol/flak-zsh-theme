# Colors used in flak.zsh-theme
# by caesarsol <cesare.soldini@gmail.com>

function to_rgb() {
  CODE=$1
  NUM=$(( CODE - 16 ))
  R=$(( (NUM / 6 / 6) % 6 ))
  G=$(( (NUM / 6) % 6 ))
  B=$(( (NUM) % 6 ))
  RGB="$R$G$B"
  print $RGB
}

function from_rgb() {
  RGB=$1
  RV=$(( (RGB / 100) % 10 ))
  GV=$(( (RGB / 10) % 10 ))
  BV=$(( (RGB / 1) % 10 ))
  NUM=$(( RV*6*6 + GV*6 + BV ))
  CODE=$(( NUM + 16 ))
  print -f "%03d" $CODE
}

function to_grey() {
  CODE=$1
  if [[ $CODE == '000' ]]; then
    print '0'
  else
    print $(( CODE - 232 + 1 ))
  fi
}

function from_grey() {
  GG=$1
  if [[ $GG == 0 ]]; then
    print '000'
  else
    print $(( GG + 232 - 1))
  fi
}

function rgb_test() {
  for CODE in {016..231}; do
    [[ $CODE == $(from_rgb $(to_rgb $CODE)) ]] || print "Error with $CODE! to_rgb: $(to_rgb $CODE) from_rgb: $(from_rgb $(to_rgb $CODE))"
  done
}

function rgb_spectrum() {
  # for i in $(seq 0 $(echo 6i 555 p | dc)); echo $i 6o p | dc
  # FOREGROUNDS
  for CODE in {016..231}; do
    #printf "\033[48;05;%03dm %03d \033[00m" $CODE $(to_rgb $CODE)
    print -n -P -- "$FG[$CODE] $(to_rgb $CODE) %f"
    [[ $(( (CODE - 16 + 1) % 36 )) == 0 ]] && print
  done
  print
  for CODE in {232..255}; do
    print -n -P -- "$FG[$CODE] $(to_grey $CODE) %f"
  done
  print
  # BACKGROUNDS
  print
  for CODE in {016..231}; do
    #printf "\033[48;05;%03dm %03d \033[00m" $CODE $(to_rgb $CODE)
    print -n -P -- "$BG[$CODE] $(to_rgb $CODE) %k"
    [[ $(( (CODE - 16 + 1) % 36 )) == 0 ]] && print
  done
  print
  for CODE in {232..255}; do
    print -n -P -- "$BG[$CODE] $(to_grey $CODE) %k"
  done
  print
}

function rgb() {
  RGB=$1
  print -- "$FG[$(from_rgb $RGB)]"
}

function rgb_bg() {
  RGB=$1
  print -- "$BG[$(from_rgb $RGB)]"
}

function grey() {
  GG=$1
  print -- "$FG[$(from_grey $GG)]"
}

function grey_bg() {
  GG=$1
  print -- "$BG[$(from_grey $GG)]"
}

function rgbecho() {
  COLOR=$1
  shift
  echo -n "$(rgb $COLOR)$*"
}

function greybgecho() {
  COLOR=$1
  shift
  echo -n "$(grey_bg $COLOR)$*"
}
