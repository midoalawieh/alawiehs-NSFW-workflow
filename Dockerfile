FROM runpod/pytorch:1.0.2-cu1281-torch280-ubuntu2404

ENV PYTHONUNBUFFERED=1
WORKDIR /workspace

RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    unzip \
    rsync \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir jupyterlab

RUN git clone https://github.com/Comfy-Org/ComfyUI.git /workspace/ComfyUI
WORKDIR /workspace/ComfyUI
RUN pip install --no-cache-dir -r requirements.txt

WORKDIR /workspace

COPY start.sh /start.sh
COPY setup_assets.sh /setup_assets.sh
RUN chmod +x /start.sh /setup_assets.sh

EXPOSE 8888 8188

CMD ["/start.sh"]
