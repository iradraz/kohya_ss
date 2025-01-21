#!/bin/bash

BASE_DIR="/workspace"
DOWNLOAD_FLAG="$BASE_DIR/.download_done"

FLAG_FILE="$BASE_DIR/.setup_done"

setup_environment() {
    ### this function is just an habit from old scripts, not really needed in kohya_ss
    touch "$FLAG_FILE"  # Create flag file
}

# Main function to orchestrate the tasks
main() {
    BASHRC_CONTENT="
# Automatically activate virtual environment
if [ -d \"/workspace/venv\" ]; then
    source /workspace/venv/bin/activate
    alias python='/workspace/venv/bin/python'
    alias pip='/workspace/venv/bin/pip'
fi
"
    echo "$BASHRC_CONTENT" >> ~/.bashrc
    if [ ! -f "$FLAG_FILE" ]; then
        echo "Running setup environment..."

		source ~/.bashrc
		rsync -av /tmp/venv/ $VENV_DIR
        rsync -av /tmp/kohya_ss/ $BASE_DIR/kohya_ss
		sed -i 's|VIRTUAL_ENV=.*|VIRTUAL_ENV=/workspace/venv|' $VENV_DIR/bin/activate
		sed -i 's|/usr/bin|/workspace/venv|g' $VENV_DIR/pyvenv.cfg
		find /workspace/venv/bin -type f -exec sed -i '1s|^#!/tmp/venv/bin/python|#!/workspace/venv/bin/python|' {} \;
        rm -rf /tmp/venv/
        rm -rf /tmp/kohya_ss/
		source $VENV_DIR/bin/activate
		
        setup_environment
		
		# cd $BASE_DIR/fluxgym && python $BASE_DIR/fluxgym/app.py &
		jupyter lab --allow-root --no-browser --port=8888 --ip=* --ServerApp.terminado_settings="{\"shell_command\":[\"/bin/bash\"]}" --ServerApp.token=$SECRET --ServerApp.allow_origin=* --ServerApp.root_dir="/" &
		bash -x $BASE_DIR/kohya_ss/gui.sh
    else
        echo "Setup already completed. Skipping setup_environment."
        source ~/.bashrc
        rm -rf /tmp/venv/
        rm -rf /tmp/kohya_ss/
		jupyter lab --allow-root --no-browser --port=8888 --ip=* --ServerApp.terminado_settings="{\"shell_command\":[\"/bin/bash\"]}" --ServerApp.token=$SECRET --ServerApp.allow_origin=* --ServerApp.root_dir="/" &
        # bash -x $BASE_DIR/kohya_ss/gui.sh
        python kohya_gui.py --headless --listen 0.0.0.0
    fi

}

# Call the main function
main

