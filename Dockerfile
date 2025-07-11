# DeepSeek Coder Training Environment
FROM runpod/pytorch:2.0.1-py3.10-cuda11.8.0-devel-ubuntu22.04

# Install system packages
RUN apt-get update && apt-get install -y \
    git \
    wget \
    unzip \
    zip \
    curl \
    nano \
    vim \
    htop \
    tmux \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Install Python packages for fine-tuning
RUN pip install --no-cache-dir \
    transformers==4.36.2 \
    peft==0.7.1 \
    bitsandbytes==0.41.3 \
    accelerate==0.25.0 \
    datasets==2.16.1 \
    torch==2.0.1 \
    tqdm \
    jsonlines \
    huggingface-hub \
    wandb \
    tensorboard

# Pre-download model files (just download, don't load into memory)
RUN python -c "from huggingface_hub import snapshot_download; \
    snapshot_download('deepseek-ai/deepseek-coder-6.7b-base', \
    cache_dir='/workspace/model_cache', \
    local_files_only=False)"

# Set HF cache to use our pre-downloaded models
ENV HF_HOME=/workspace/model_cache

# Create working directories
RUN mkdir -p /workspace/scripts /workspace/data /workspace/model

# Create a startup script
RUN echo '#!/bin/bash\n\
echo "🚀 DeepSeek Coder Fine-Tuning Environment"\n\
echo "========================================"\n\
echo ""\n\
echo "Environment:"\n\
echo "  - PyTorch 2.0.1 with CUDA 11.8"\n\
echo "  - DeepSeek Coder 6.7B base model (pre-downloaded in /workspace/model_cache)"\n\
echo "  - PEFT/LoRA libraries installed"\n\
echo ""\n\
echo "GPU Status:"\n\
nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv\n\
echo ""\n\
echo "Ready for fine-tuning!"\n\
cd /workspace\n\
exec /bin/bash\n' > /startup.sh && chmod +x /startup.sh

# Default command
CMD ["/startup.sh"]