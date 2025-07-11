# SVML Coder Training Environment

Docker image for fine-tuning DeepSeek Coder 6.7B model with SVML+AMM support.

## What's Included

- PyTorch 2.0.1 with CUDA 11.8 support
- DeepSeek Coder 6.7B base model (pre-downloaded)
- PEFT/LoRA libraries for efficient fine-tuning
- All necessary dependencies for training

## Usage

This image is designed for use with RunPod or other GPU cloud providers:

```bash
docker pull scalabl3/svml-coder-training:latest
```

## RunPod Template Settings

- **Container Image**: `scalabl3/svml-coder-training:latest`
- **Container Disk**: 100 GB
- **Volume Disk**: 100 GB
- **Volume Mount Path**: `/workspace`
- **TCP Ports**: 22 (SSH)

## Building Locally

```bash
docker build -t svml-coder-training .
```

## Automated Builds

This repository uses GitHub Actions to automatically build and push updates to Docker Hub.