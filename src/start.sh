#!/bin/bash

BLUE="\033[0;34m"
GREEN="\033[0;32m"
RESET="\033[0m"

# Set default mode
MODE="dev"

# Parse arguments using getopts
while getopts ":m:" opt; do
  case $opt in
  m)
    MODE="$OPTARG"
    ;;
  \?)
    echo "Usage: $0 [-m mode]"
    exit 1
    ;;
  esac
done

# Ignore parsed arguments
shift "$((OPTIND - 1))"

echo # Empty line
echo -e "${BLUE}Initializing Docker...${RESET}"
echo # Empty line

source .env.local

# Use the MODE variable to choose the appropriate docker-compose file
if [ "$MODE" == "prod" ]; then
  DOCKER_COMPOSE_FILE="docker-compose-prod.yml"
else
  DOCKER_COMPOSE_FILE="docker-compose.yml"
fi

# Start Docker Compose services
docker-compose --env-file ".env.local" -f "$DOCKER_COMPOSE_FILE" -p "$PROJECT_NAME" up -d

echo # Empty line
echo -e "${GREEN}Docker initialization completed.${RESET}"
echo # Empty line
