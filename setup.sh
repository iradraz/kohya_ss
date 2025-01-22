#!/bin/bash

BASE_DIR="/workspace"
DOWNLOAD_FLAG="$BASE_DIR/.download_done"
MODEL_DIR="$BASE_DIR/kohya_ss/models"
FLAG_FILE="$BASE_DIR/.setup_done"

download_models() {
    local running_downloads=0
    cd "$MODEL_DIR"
    # Process each line output by the Python script
    python /tmp/read_yaml.py | while read -r CATEGORY MODEL_URL NAME; do
        # Define the destination path
        local DEST_DIR="$MODEL_DIR/$CATEGORY"
        mkdir -p $DEST_DIR
        echo "Downloading $NAME ($CATEGORY) from $MODEL_URL to $DEST_DIR..."
    cd $DEST_DIR
        # Create the directory if it doesn't exist
        # Start the download in the background
        {
            aria2c --file-allocation=none -q --min-split-size=500M -x 6 -d "$DEST_DIR" -o "$NAME" "$MODEL_URL"
            if [[ $? -eq 0 ]]; then
                echo "Download finished: $DEST_PATH"
            else
                echo "Download failed: $DEST_PATH"
            fi
        } &
        # Increment the counter for running downloads
        ((running_downloads++))

        # If we've reached the max parallel downloads, wait for one to finish
        while (( running_downloads >= MAX_PARALLEL_DOWNLOADS )); do
            wait -n  # Wait for any one background job to complete
            ((running_downloads--))  # Decrement the counter when a job finishes
        done

    done
    touch $DOWNLOAD_FLAG
}

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



		jupyter lab --allow-root --no-browser --port=8888 --ip=* --ServerApp.terminado_settings="{\"shell_command\":[\"/bin/bash\"]}" --ServerApp.token=$SECRET --ServerApp.allow_origin=* --ServerApp.root_dir="/" &

        if [ ! -f "$DOWNLOAD_FLAG" ]; then
            echo "Downloading models..."
            download_models
            touch "$DOWNLOAD_FLAG"  # Create the flag file
        else
            echo "Models already downloaded. Skipping download_models."
        fi

		cd $BASE_DIR/kohya_ss && python $BASE_DIR/kohya_ss/kohya_gui.py --headless --listen 0.0.0.0
    else
        echo "Setup already completed. Skipping setup_environment."
        source ~/.bashrc
        rm -rf /tmp/venv/
        rm -rf /tmp/kohya_ss/
		jupyter lab --allow-root --no-browser --port=8888 --ip=* --ServerApp.terminado_settings="{\"shell_command\":[\"/bin/bash\"]}" --ServerApp.token=$SECRET --ServerApp.allow_origin=* --ServerApp.root_dir="/" &
        # bash -x $BASE_DIR/kohya_ss/gui.sh
        cd $BASE_DIR/kohya_ss && python $BASE_DIR/kohya_ss/kohya_gui.py --headless --listen 0.0.0.0
    fi
}

# Call the main function
main

