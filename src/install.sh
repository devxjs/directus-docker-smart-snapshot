#!/bin/bash

# Set default mode
MODE="dev"

# Parse arguments using getopts
while getopts ":m:" opt; do
    case $opt in
    m)
        MODE="$OPTARG"
        ;;
    \?)
        echo "Usage: $0 [-m mode] <sudo_password>"
        exit 1
        ;;
    esac
done

# Ignore parsed arguments
shift "$((OPTIND - 1))"

# Retrieve the password passed as a parameter
sudo_password="$1"

if [ $# -ne 1 ]; then
    echo "Usage: $0 <sudo_password>"
    exit 1
fi

# Use the MODE variable to choose the appropriate docker-compose file
if [ "$MODE" == "prod" ]; then
    DOCKER_COMPOSE_FILE="docker-compose-prod.yml"
else
    DOCKER_COMPOSE_FILE="docker-compose.yml"
fi

# Retrieve the password passed as a parameter
sudo_password="$1"

BLUE="\033[0;34m"
GREEN="\033[0;32m"
ORANGE="\033[0;33m"
RED="\033[0;31m"
RESET="\033[0m"

# Check if sudo password is correct by attempting a sudo operation
if ! echo "$sudo_password" | sudo -S true >/dev/null 2>&1; then
    echo -e "${RED}Incorrect sudo password.${RESET}"
    exit 1
fi

# Check if nvm is installed
if [ -s "$HOME/.nvm/nvm.sh" ]; then
    source "$HOME/.nvm/nvm.sh"
    nvm install
    nvm use
    npm i
else
    echo "nvm is not installed or nvm.sh is not found in the expected location."
fi

echo -e "${BLUE}Initializing backend...${RESET}"
echo -e "${BLUE}Initializing Docker...${RESET}"

# Load environment variables from .env.local
source .env.local

# Start Docker Compose services
docker-compose --env-file ".env.local" -f "$DOCKER_COMPOSE_FILE" -p "$PROJECT_NAME" up -d
echo -e "${GREEN}Docker Compose services started.${RESET}"

# Function to adjust permissions of a folder
adjust_permissions() {
    target_folder="$1"
    target_owner="$2"
    target_group="$3"

    # Create the folder if it doesn't exist
    if [ ! -d "$target_folder" ]; then
        echo -e "${ORANGE}Folder $target_folder does not exist. Creating...${RESET}"
        mkdir -p "$target_folder"
        echo -e "${GREEN}Folder $target_folder created.${RESET}"
    fi

    current_owners=$(stat -c '%u:%g' "$target_folder")

    if [ "$current_owners" != "$target_owner:$target_group" ]; then
        echo -e "${ORANGE}Folder $target_folder does not have the necessary permissions.${RESET}"
        echo -e "${BLUE}Updating permissions...${RESET}"
        # Adjust folder permissions using sudo password
        echo "$sudo_password" | sudo -S chown -R "$target_owner:$target_group" "$target_folder"
        echo -e "${GREEN}Permissions for folder $target_folder updated.${RESET}"
    fi
}

# Adjust permissions of required folders
adjust_permissions "./uploads" "1000" "1000"
adjust_permissions "./extensions" "1000" "1000"
adjust_permissions "./snapshots" "1000" "1000"
echo -e "${GREEN}Folder permissions adjusted.${RESET}"

echo -e "${GREEN}Docker initialization completed.${RESET}"

echo -e "${BLUE}Initializing Directus...${RESET}"
echo -e "${BLUE}Initializing automatic snapshot system...${RESET}"

for i in {1..30}; do
    echo -ne "${ORANGE}["
    for ((j = 0; j < i; j++)); do echo -n "#"; done
    for ((j = i; j < 30; j++)); do echo -n " "; done
    echo -ne "] $i/30 (seconds)\r"
    sleep 1
done

# Create a new admin user using the Directus API
echo -e "${BLUE}Attempting to log in as admin...${RESET}"
get_admin_user_token_response=$(curl -X POST "$DIRECTUS_URL/auth/login" -H "Content-Type: application/json" -d '{
	"email": "'"${DIRECTUS_ADMIN_EMAIL}"'",
	"password": "'"${DIRECTUS_ADMIN_PASSWORD}"'"
}')
echo -e "${GREEN}Logged in as admin successfully.${RESET}"

# Extract access token using string manipulation
access_token=$(echo "$get_admin_user_token_response" | sed -n 's/.*"access_token":"\([^"]*\)".*/\1/p')

# Get user roles using Directus API
echo -e "${BLUE}Getting user roles...${RESET}"
get_users_roles_response=$(curl -X GET "$DIRECTUS_URL/roles" -H "Authorization: Bearer $access_token" -H "Content-Type: application/json")
echo -e "${GREEN}User roles obtained.${RESET}"

admin_role_id=$(echo "$get_users_roles_response" | grep -o '{"id":"[^"]*","name":"Administrator"' | cut -d '"' -f 4)

create_admin_user=$(curl -X POST "$DIRECTUS_URL/users" -H "Authorization: Bearer $access_token" -H "Content-Type: application/json" -d '{
	"first_name": "directus-docker-smart-snapshot",
	"role": "'"${admin_role_id}"'",
    "token": "'"${DIRECTUS_ADMIN_STATIC_TOKEN}"'"
}')
echo -e "${GREEN}Admin user created successfully.${RESET}"

echo -e "${GREEN}Automatic snapshot system initialization successful.${RESET}"
echo -e "${GREEN}Directus initialization completed.${RESET}"

docker-compose --env-file ".env.local" -p "$PROJECT_NAME" down
echo -e "${GREEN}Stopping Docker Compose services.${RESET}"
echo -e "${GREEN}Directus initialization completed.${RESET}"

chmod +x './start.sh'
./start.sh -m "$MODE"
