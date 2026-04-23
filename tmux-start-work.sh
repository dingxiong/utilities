#!/usr/bin/env bash

SESSION="work"

# If session exists, ask whether to attach or kill
if tmux has-session -t "$SESSION" 2>/dev/null; then
    read -p "Session '$SESSION' already exists. Attach (default) or Kill? [A/k]: " choice
    case "$choice" in
        k|K)
            echo "Killing session '$SESSION'..."
            tmux kill-session -t "$SESSION"
            ;;
        *)
            echo "Attaching to existing session..."
            exec tmux attach-session -t "$SESSION"
            exit 0
            ;;
    esac
fi

# Create session detached
tmux new-session -d -s "$SESSION" -n notes

# -----------------------------------------------------------------------------
# --- Window 0: notes ---
tmux send-keys -t "$SESSION:notes" 'cd ~/code/programming-books' C-m
tmux send-keys -t "$SESSION:notes.0" 'vim .' C-m

# Create right pane group (main-vertical)
tmux split-window -h -t "$SESSION:notes"

# Inside right group: 3 vertical panes
tmux split-window -v -t "$SESSION:notes.1"
tmux split-window -v -t "$SESSION:notes.2"

tmux send-keys -t "$SESSION:notes.1" 'cd ~/code/programming-books' C-m
tmux send-keys -t "$SESSION:notes.1" 'cd dev-notes' C-m

tmux send-keys -t "$SESSION:notes.2" 'cd ~/code/programming-books' C-m

tmux send-keys -t "$SESSION:notes.3" 'cd ~/code/programming-books' C-m
tmux send-keys -t "$SESSION:notes.3" 'cd dev-notes' C-m
tmux send-keys -t "$SESSION:notes.3" 'mdbook serve' C-m

# -----------------------------------------------------------------------------
# --- Window 1: zip notes ---
name="zip notes"
tmux new-window -t "$SESSION" -n "$name"
tmux send-keys -t "$SESSION:$name" 'cd ~/code/zip' C-m
tmux send-keys -t "$SESSION:$name.0" 'vim .' C-m
tmux select-layout -t "$SESSION:$name" even-horizontal
tmux split-window -h -t "$SESSION:$name"

tmux send-keys -t "$SESSION:$name.1" 'cd ~/code/zip' C-m

# -----------------------------------------------------------------------------
# --- Window 2–9 (repeating pattern) ---
make_two_pane_window() {
    local name="$1"
    local dir="$2"
    local cmd1="$3"
    local cmd2="$4"

    tmux new-window -t "$SESSION" -n "$name"
    tmux send-keys -t "$SESSION:$name" "cd $dir" C-m
    tmux send-keys -t "$SESSION:$name.0" "$cmd1" C-m
    tmux split-window -h -t "$SESSION:$name"

    tmux send-keys -t "$SESSION:$name.1" "cd $dir" C-m
    tmux send-keys -t "$SESSION:$name.1" "$cmd2" C-m
    tmux select-layout -t "$SESSION:$name" even-horizontal
}

make_two_pane_window "config"   "~/code/configure"              "echo first pane" "echo second pane"
make_two_pane_window "code"     "~/code"                        "echo first pane" "echo second pane"
make_two_pane_window "code-2"   "~/code"                        "echo first pane" "echo second pane"
make_two_pane_window "code-3"   "~/code"                        "echo third pane" "echo forth pane"
make_two_pane_window "code-4"   "~/code"                        "echo first pane" "echo second pane"
make_two_pane_window "code-5"   "~/code"                        "echo first pane" "echo second pane"
make_two_pane_window "zip-run"  "~/code/evergreen/website"      "echo first pane" "echo second pane"
make_two_pane_window "systems"  "~/code/systems"                "echo first pane" "echo second pane"

# Attach
tmux attach-session -t "$SESSION"

