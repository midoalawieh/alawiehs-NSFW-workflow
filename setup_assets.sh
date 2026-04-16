#!/usr/bin/env bash
set -e

COMFY_DIR="/workspace/ComfyUI"
CUSTOM_NODES_DIR="$COMFY_DIR/custom_nodes"

HF_TOKEN="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"
CIVITAI_API_KEY="1def63cb9c41ae060d12d233d9c3b017"

mkdir -p "$CUSTOM_NODES_DIR"

download_file_if_missing() {
  local url="$1"
  local out="$2"
  local auth_header="${3:-}"

  mkdir -p "$(dirname "$out")"

  if [ -f "$out" ]; then
    echo "Skipping existing file: $out"
    return 0
  fi

  echo "Downloading: $out"
  if [ -n "$auth_header" ]; then
    curl -L --fail -H "$auth_header" -o "$out" "$url"
  else
    curl -L --fail -o "$out" "$url"
  fi
}

replace_file_always() {
  local url="$1"
  local out="$2"
  local auth_header="${3:-}"

  mkdir -p "$(dirname "$out")"

  echo "Replacing file: $out"
  if [ -n "$auth_header" ]; then
    curl -L --fail -H "$auth_header" -o "$out" "$url"
  else
    curl -L --fail -o "$out" "$url"
  fi
}

clone_node_if_missing() {
  local repo_url="$1"
  local folder_name="$2"
  local target_dir="$CUSTOM_NODES_DIR/$folder_name"

  if [ -d "$target_dir" ]; then
    echo "Skipping existing custom node: $folder_name"
    return 0
  fi

  echo "Cloning custom node: $repo_url"
  git clone --depth 1 "$repo_url" "$target_dir"
}

install_node_requirements() {
  local node_dir="$1"

  if [ -f "$node_dir/requirements.txt" ]; then
    echo "Installing requirements for: $node_dir"
    pip install --no-cache-dir -r "$node_dir/requirements.txt" || true
  fi

  if [ -f "$node_dir/install.py" ]; then
    echo "Found install.py in: $node_dir (not auto-running)"
  fi
}

echo "=== CUSTOM NODES ==="

clone_node_if_missing "https://github.com/ltdrdata/ComfyUI-Impact-Pack" "ComfyUI-Impact-Pack"
clone_node_if_missing "https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes" "ComfyUI_Comfyroll_CustomNodes"
clone_node_if_missing "https://github.com/rgthree/rgthree-comfy" "rgthree-comfy"
clone_node_if_missing "https://github.com/ltdrdata/ComfyUI-Impact-Subpack" "ComfyUI-Impact-Subpack"
clone_node_if_missing "https://github.com/JPS-GER/ComfyUI_JPS-Nodes" "ComfyUI_JPS-Nodes"
clone_node_if_missing "https://github.com/ltdrdata/ComfyUI-Inspire-Pack" "ComfyUI-Inspire-Pack"
clone_node_if_missing "https://github.com/WASasquatch/was-node-suite-comfyui" "was-node-suite-comfyui"
clone_node_if_missing "https://github.com/Comfy-Org/ComfyUI-Manager.git" "ComfyUI-Manager"

install_node_requirements "$CUSTOM_NODES_DIR/ComfyUI-Impact-Pack"
install_node_requirements "$CUSTOM_NODES_DIR/ComfyUI_Comfyroll_CustomNodes"
install_node_requirements "$CUSTOM_NODES_DIR/rgthree-comfy"
install_node_requirements "$CUSTOM_NODES_DIR/ComfyUI-Impact-Subpack"
install_node_requirements "$CUSTOM_NODES_DIR/ComfyUI_JPS-Nodes"
install_node_requirements "$CUSTOM_NODES_DIR/ComfyUI-Inspire-Pack"
install_node_requirements "$CUSTOM_NODES_DIR/was-node-suite-comfyui"
install_node_requirements "$CUSTOM_NODES_DIR/ComfyUI-Manager"

echo "=== PATCHED FILES ==="

replace_file_always \
  "https://huggingface.co/LuciAl/ModelsGen/resolve/main/nodes_utils_logic.py" \
  "$COMFY_DIR/custom_nodes/ComfyUI_Comfyroll_CustomNodes/nodes/nodes_utils_logic.py"

replace_file_always \
  "https://huggingface.co/LuciAl/ModelsGen/resolve/main/nsfw_propmts.txt" \
  "$COMFY_DIR/custom_nodes/ComfyUI-Inspire-Pack/prompts/example/nsfw_propmts.txt"

echo "=== MODELS ==="

download_file_if_missing \
  "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/flux1-dev.safetensors" \
  "$COMFY_DIR/models/unet/flux1-dev.safetensors" \
  "Authorization: Bearer $HF_TOKEN"

download_file_if_missing \
  "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/ae.safetensors" \
  "$COMFY_DIR/models/vae/ae.safetensors" \
  "Authorization: Bearer $HF_TOKEN"

download_file_if_missing \
  "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors" \
  "$COMFY_DIR/models/text_encoders/clip_l.safetensors"

download_file_if_missing \
  "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors" \
  "$COMFY_DIR/models/text_encoders/t5xxl_fp16.safetensors"

download_file_if_missing \
  "https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/4x_NMKD-Siax_200k.pth" \
  "$COMFY_DIR/models/upscale_models/4x_NMKD-Siax_200k.pth"

download_file_if_missing \
  "https://civitai.com/api/download/models/2155386?type=Model&format=SafeTensor&size=pruned&fp=fp16" \
  "$COMFY_DIR/models/checkpoints/lustify.safetensors" \
  "Authorization: Bearer $CIVITAI_API_KEY"

download_file_if_missing \
  "https://civitai.red/api/download/models/1620724?type=Model&format=SafeTensor&size=pruned&fp=fp16" \
  "$COMFY_DIR/models/checkpoints/biglust.safetensors" \
  "Authorization: Bearer $CIVITAI_API_KEY"

download_file_if_missing \
  "https://civitai.com/api/download/models/135867?type=Model&format=SafeTensor" \
  "$COMFY_DIR/models/loras/detail-tweaker-sdxl.safetensors" \
  "Authorization: Bearer $CIVITAI_API_KEY"

download_file_if_missing \
  "https://civitai.com/api/download/models/262705?type=Model&format=SafeTensor" \
  "$COMFY_DIR/models/loras/real_humans.safetensors" \
  "Authorization: Bearer $CIVITAI_API_KEY"

echo "=== SETUP COMPLETE ==="
