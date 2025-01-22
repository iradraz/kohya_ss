import yaml

# Load the YAML file
with open("/tmp/config.yaml", "r") as file:
    config = yaml.safe_load(file)

# Loop through each category and each model within that category
for category, models in config.items():
    for model in models:
        # Print the category, URL, and name separated by spaces
        print(category, model["url"], model["name"])

