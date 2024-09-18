#!/bin/bash

# Temporarily alias emacs to cat
alias emacs='cat'

# Run your work session (e.g., opening a shell so you can use the alias)
echo "emacs is now aliased to cat. Type 'exit' to end the session."
bash

# After exiting the session, the alias will be removed
echo "Session ended. emacs is restored to its normal function."
