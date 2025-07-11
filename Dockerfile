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

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install Python packages for fine-tuning
# First upgrade pip
RUN pip install --no-cache-dir --upgrade pip

# Install base packages first (smaller)
RUN pip install --no-cache-dir \
    transformers==4.36.2 \
    peft==0.7.1 \
    accelerate==0.25.0 \
    datasets==2.16.1 \
    tqdm \
    jsonlines \
    huggingface-hub

# Note: PyTorch with CUDA 12.1 will be installed on first run
# This avoids GitHub Actions disk space issues
# Run this command in the container:
# pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# Model will be downloaded on first use to avoid build size limits
# Set HF cache directory for when model is downloaded
ENV HF_HOME=/workspace/model_cache

# Create working directories
RUN mkdir -p /workspace/scripts /workspace/data /workspace/model

# Create a startup script
RUN echo '#!/bin/bash\n\
source /opt/venv/bin/activate\n\
echo "🚀 DeepSeek Coder Fine-Tuning Environment"\n\
echo "========================================"\n\
echo ""\n\
\n\
# Check if PyTorch is installed\n\
if ! python -c "import torch" 2>/dev/null; then\n\
    echo "📦 First run detected - installing PyTorch with CUDA 12.1..."\n\
    echo "This will take a few minutes but only happens once."\n\
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121\n\
    pip install bitsandbytes xformers\n\
    echo "✅ PyTorch installation complete!"\n\
fi\n\
\n\
echo "Environment:"\n\
echo "  - PyTorch with CUDA 12.1 (RTX 4090 optimized)"\n\
echo "  - DeepSeek Coder 6.7B base model (will download on first use)"\n\
echo "  - PEFT/LoRA libraries installed"\n\
echo "  - Virtual environment activated at /opt/venv"\n\
echo ""\n\
echo "GPU Status:"\n\
nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv\n\
echo ""\n\
echo "PyTorch CUDA Check:"\n\
python -c "import torch; print(f\"PyTorch: {torch.__version__}\"); print(f\"CUDA Available: {torch.cuda.is_available()}\"))" 2>/dev/null || echo "PyTorch will be installed on first run"\n\
echo ""\n\
echo "Ready for fine-tuning!"\n\
cd /workspace\n\
exec /bin/bash\n' > /startup.sh && chmod +x /startup.sh

# Default command
CMD ["/startup.sh"]