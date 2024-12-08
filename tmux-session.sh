#!/bin/bash

SESH="aoc2024"

tmux has-session -t $SESH 2>/dev/null

if [ $? != 0 ]; then
  tmux new-session -d -s $SESH -n "editor"

  tmux send-keys -t $SESH:editor "cd ~/projects/advent-of-code-2024" C-m
  tmux send-keys -t $SESH:editor "nvim ." C-m

  tmux new-window -t $SESH -n "term"
  tmux send-keys -t $SESH:term "cd ~/projects/advent-of-code-2024" C-m

  tmux select-window -t $SESH:editor
fi

tmux attach-session -t $SESH
