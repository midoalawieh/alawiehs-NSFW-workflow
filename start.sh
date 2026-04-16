#!/usr/bin/env bash
set -e

mkdir -p /workspace/logs

echo "Running startup asset setup..."
/setup_assets.sh > /workspace/logs/setup_assets.log 2>&1

echo "Starting JupyterLab..."
nohup jupyter lab \
  --ip=0.0.0.0 \
  --port=8888 \
  --no-browser \
  --allow-root \
  --NotebookApp.token='' \
  --notebook-dir=/workspace \
  > /workspace/logs/jupyter.log 2>&1 &

echo "Starting ComfyUI..."
cd /workspace/ComfyUI
python3 main.py --listen 0.0.0.0 --port 8188 > /workspace/logs/comfyui.log 2>&1
