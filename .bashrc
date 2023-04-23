# Runs whenever a new shell is opened, but NOT the FIRST (login) shell.
# Calls bash_profile, which originally only runs when FIRST shell (login shell) opens.
# Result:
# 1) .bashrc ONLY runs when shell opens for second or later time
# 2) .bash_profile RUNS EVERY TIME ANY SHELL OPENS (login or non-login).

# CONCLUSION: Do not use this file, it does not run every time (runs all times except first).
# CONCLUSION: We do not have a file that ONLY runs on first shell.

[ -n "$PS1" ] && source ~/.bash_profile;
