#!/usr/bin/env bash
# external tool for svn merge-tool-cmd

BASE=$1
THEIRS=$2
MINE=$3
MERGED=$4
WCPATH=$5

# window titles
TITLE_MERGED=$MERGED
TITLE_BASE=BASE.${BASE##*.}
TITLE_THEIRS=THEIRS.${THEIRS##*.}
TITLE_MINE=MINE

vimdiff $THEIRS $BASE $MINE -c ":bo sp $MERGED" -c ":diffthis" -c "setl stl=$TITLE_MERGED | wincmd W | setl stl=$TITLE_MINE | wincmd W | setl stl=$TITLE_BASE | wincmd W | setl stl=$TITLE_THEIRS | wincmd j"

