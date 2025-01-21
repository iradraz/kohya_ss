# Kohya_ss

Kohya_ss is a Dockerized environment for training LoRA models using PyTorch with CUDA support. This setup leverages NVIDIA CUDA capabilities and provides a convenient interface for educational and research purposes in the realm of deep learning.

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [License](#license)
- [Contributing](#contributing)

## Features

- Pre-configured Docker environment with CUDA 12.1 and Ubuntu 22.04
- Python 3.10 with essential packages for deep learning
- Jupyter Lab for interactive coding and experimentation
- Simple setup script for quick environment preparation

## Requirements

- Docker installed on your machine
- An NVIDIA GPU (optional but recommended for GPU acceleration)
- NVIDIA Driver and NVIDIA Container Toolkit

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/iradraz/kohya_ss.git
   cd kohya_ss
   ```

2. Build the Docker image:
   ```bash
   docker build -t kohya_ss .
   ```

3. Run the Docker container:
   ```bash
   docker run --gpus all -it -p 7860:7860 -p 8888:8888 -v $(pwd):/workspace kohya_ss
   ```

This command exposes ports for both Gradio and Jupyter Lab, allowing you to access the interfaces from your browser.

## Usage

- After starting the container, the Gradio app will be accessible at `http://localhost:7860`.
- Jupyter Lab will be available at `http://localhost:8888`, along with a temporary access token. 

### Configure Environment

The setup script `setup.sh` will handle the activation of the virtual environment and ensure all the necessary setups are in place. The script checks for the completion of the setup and avoids re-running the process unnecessarily.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Contributing

Contributions are welcome! If you have suggestions or improvements, please feel free to submit a pull request or open an issue.

---

For more information, check the documentation and resources provided in the repository.
