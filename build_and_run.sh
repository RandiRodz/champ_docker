#!/bin/bash

# CHAMP ROS2 Docker Helper Script
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

print_header() {
    echo -e "${GREEN}======================================${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${GREEN}======================================${NC}"
}

print_error() {
    echo -e "${RED}ERROR: $1${NC}"
}

print_info() {
    echo -e "${YELLOW}INFO: $1${NC}"
}

usage() {
    echo "CHAMP ROS2 Docker Helper"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  build           Build the Docker image"
    echo "  run             Run container in interactive mode"
    echo "  run-bg          Run container in background"
    echo "  stop            Stop running container"
    echo "  shell           Enter shell of running container"
    echo "  down            Stop and remove container"
    echo "  logs            Display container logs"
    echo "  clean           Remove all containers and images"
    echo "  display-setup   Setup X11 display for GUI"
    echo "  help            Show this help message"
    echo ""
}

setup_display() {
    print_header "Setting up X11 Display"
    if command -v xhost &> /dev/null; then
        xhost +local:docker
        print_info "X11 display access granted to Docker"
    else
        print_error "xhost not found. X11 display may not work properly."
        print_info "Install xhost or configure X11 forwarding manually"
    fi
}

build_image() {
    print_header "Building CHAMP ROS2 Docker Image"
    cd "$SCRIPT_DIR"
    docker-compose build
    print_info "Build completed successfully!"
}

run_interactive() {
    print_header "Starting CHAMP ROS2 Container (Interactive)"
    cd "$SCRIPT_DIR"
    setup_display
    docker-compose up
}

run_background() {
    print_header "Starting CHAMP ROS2 Container (Background)"
    cd "$SCRIPT_DIR"
    setup_display
    docker-compose up -d
    print_info "Container started in background"
    print_info "Run './$0 shell' to enter the container"
    print_info "Run './$0 logs' to view container output"
}

enter_shell() {
    print_header "Entering Container Shell"
    docker exec -it champ_ros2 bash
}

stop_container() {
    print_header "Stopping Container"
    docker-compose stop
    print_info "Container stopped"
}

down_container() {
    print_header "Removing Container"
    docker-compose down
    print_info "Container removed"
}

show_logs() {
    print_header "Container Logs"
    docker-compose logs -f
}

clean_all() {
    print_header "Cleaning Up Docker Resources"
    print_info "Stopping container..."
    docker-compose down 2>/dev/null || true
    
    print_info "Removing volume..."
    docker volume rm champ_docker_build 2>/dev/null || true
    docker volume rm champ_docker_install 2>/dev/null || true
    
    print_info "Removing image..."
    docker rmi champ:ros2-humble 2>/dev/null || true
    
    print_info "Cleanup completed!"
}

# Main script logic
case "${1:-help}" in
    build)
        build_image
        ;;
    run)
        run_interactive
        ;;
    run-bg)
        run_background
        ;;
    stop)
        stop_container
        ;;
    shell)
        enter_shell
        ;;
    down)
        down_container
        ;;
    logs)
        show_logs
        ;;
    clean)
        clean_all
        ;;
    display-setup)
        setup_display
        ;;
    help)
        usage
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        usage
        exit 1
        ;;
esac
