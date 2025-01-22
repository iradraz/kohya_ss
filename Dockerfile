FROM nvidia/cuda:12.1.1-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL=/bin/bash
ENV BASE_DIR=/workspace
ENV VENV_DIR=$BASE_DIR/venv
ENV PATH=$VENV_DIR/bin:$PATH
ENV DISPLAY=:1
# # Update package list and install dependencies
RUN apt-get update -y -qq && apt-get install --yes -qq --no-install-recommends \
    software-properties-common libgl1 \
    build-essential rsync aria2 \
    ffmpeg libsm6 libxext6 \
    # nvidia-cuda-toolkit \
    wget git sudo curl bash \
    vim btop glances
RUN apt install -y -qq libcudnn8 libcudnn8-dev --allow-change-held-packages

RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt install python3.10 python3-tk python3.10-distutils python3.10-venv python3.10-dev python3-pip -y --no-install-recommends -qq

RUN python3 -m venv /tmp/venv && \
    /tmp/venv/bin/pip install -q --upgrade pip
# Install voluptuous
RUN /tmp/venv/bin/pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

RUN /tmp/venv/bin/pip install --default-timeout=100 -U --no-cache-dir voluptuous pyyaml jupyterlab jupyterlab_widgets ipykernel ipywidgets
RUN git clone --recursive https://github.com/bmaltais/kohya_ss.git /tmp/kohya_ss
WORKDIR /tmp/kohya_ss/
RUN /tmp/venv/bin/python "/tmp/kohya_ss/setup/setup_linux.py" --platform-requirements-file=/tmp/kohya_ss/requirements_runpod.txt --show_stdout --no_run_accelerate
# Expose the port and set Gradio server settings
VOLUME ["/workspace"]
WORKDIR /workspace

COPY setup.sh config.yaml read_yaml.py /tmp/
EXPOSE 7860
ENV GRADIO_SERVER_NAME="0.0.0.0"

# Set the working directory and run the application
CMD ["bash","-x","/tmp/setup.sh"]
