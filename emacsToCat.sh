#!/bin/bash

# Create a temporary directory for the wrapper script
TEMP_DIR=$(mktemp -d)

# Create the temporary wrapper script
cat << 'EOF' > "$TEMP_DIR/emacs"
#!/bin/bash
cat "$@"
EOF

# Make the wrapper script executable
chmod +x "$TEMP_DIR/emacs"

# Save the current PATH
OLD_PATH="$PATH"

# Prepend the temporary directory to the PATH
export PATH="$TEMP_DIR:$PATH"

# Run a new shell session where the alias is active
exec bash
