#!/bin/bash
# start_phoenix.sh — Launch Arize Phoenix with SQLite backend
# Suitable for memory-constrained environments (8GB RAM)

set -e

echo "[vibe-poisoning] Starting Arize Phoenix on port 6006..."

export PHOENIX_WORKING_DIR="./traces"
mkdir -p "$PHOENIX_WORKING_DIR"

python -c "
import phoenix as px
import os

working_dir = os.environ.get('PHOENIX_WORKING_DIR', './traces')
print(f'[Phoenix] Working directory: {working_dir}')
print('[Phoenix] Storage: SQLite (memory-efficient mode)')
print('[Phoenix] UI: http://localhost:6006')

session = px.launch_app(
    host='0.0.0.0',
    port=6006,
)

print('[Phoenix] Running. Press Ctrl+C to stop.')
import time
while True:
    time.sleep(10)
"
