#!/bin/bash

# Student Management System Docker Helper Script

set -e

PROJECT_NAME="Student Management System"
COMPOSE_FILE="docker-compose.yml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker is not running. Please start Docker first."
        exit 1
    fi
}

# Check if docker-compose exists
check_compose() {
    if ! command -v docker-compose >/dev/null 2>&1 && ! docker compose version >/dev/null 2>&1; then
        log_error "docker-compose is not installed."
        exit 1
    fi
}

# Setup environment
setup_env() {
    if [ ! -f .env ]; then
        log_info "Creating .env file from template..."
        cp .env.docker .env
        log_warning "Please edit .env file with your actual configuration values before running."
        log_info "Required: JWT secrets, email settings, etc."
        exit 1
    fi
}

# Main commands
case "${1:-help}" in
    "start")
        log_info "Starting $PROJECT_NAME..."
        check_docker
        check_compose
        setup_env
        docker-compose -f "$COMPOSE_FILE" up -d
        log_success "Services started successfully!"
        log_info "Frontend: http://localhost:3000"
        log_info "Backend: http://localhost:5007"
        log_info "Database: localhost:5432"
        ;;

    "stop")
        log_info "Stopping $PROJECT_NAME..."
        check_docker
        check_compose
        docker-compose -f "$COMPOSE_FILE" down
        log_success "Services stopped successfully!"
        ;;

    "restart")
        log_info "Restarting $PROJECT_NAME..."
        check_docker
        check_compose
        setup_env
        docker-compose -f "$COMPOSE_FILE" restart
        log_success "Services restarted successfully!"
        ;;

    "build")
        log_info "Building $PROJECT_NAME..."
        check_docker
        check_compose
        setup_env
        docker-compose -f "$COMPOSE_FILE" build --no-cache
        log_success "Build completed successfully!"
        ;;

    "rebuild")
        log_info "Rebuilding and starting $PROJECT_NAME..."
        check_docker
        check_compose
        setup_env
        docker-compose -f "$COMPOSE_FILE" down
        docker-compose -f "$COMPOSE_FILE" build --no-cache
        docker-compose -f "$COMPOSE_FILE" up -d
        log_success "Rebuild and start completed successfully!"
        ;;

    "logs")
        check_docker
        check_compose
        if [ -n "$2" ]; then
            docker-compose -f "$COMPOSE_FILE" logs -f "$2"
        else
            docker-compose -f "$COMPOSE_FILE" logs -f
        fi
        ;;

    "status")
        check_docker
        check_compose
        log_info "Service Status:"
        docker-compose -f "$COMPOSE_FILE" ps
        ;;

    "clean")
        log_warning "This will remove all containers, volumes, and images!"
        read -p "Are you sure? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            check_docker
            check_compose
            log_info "Cleaning up..."
            docker-compose -f "$COMPOSE_FILE" down -v --rmi all
            docker system prune -f
            log_success "Cleanup completed!"
        fi
        ;;

    "reset-db")
        log_warning "This will reset the database!"
        read -p "Are you sure? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            check_docker
            check_compose
            log_info "Resetting database..."
            docker-compose -f "$COMPOSE_FILE" stop db
            docker-compose -f "$COMPOSE_FILE" rm -f db
            docker volume rm "${PROJECT_NAME,,}_postgres_data" 2>/dev/null || true
            docker-compose -f "$COMPOSE_FILE" up -d db
            log_success "Database reset completed!"
        fi
        ;;

    "help"|*)
        echo "Student Management System Docker Helper"
        echo ""
        echo "Usage: $0 <command> [options]"
        echo ""
        echo "Commands:"
        echo "  start     Start all services"
        echo "  stop      Stop all services"
        echo "  restart   Restart all services"
        echo "  build     Build all services"
        echo "  rebuild   Rebuild and start all services"
        echo "  logs      Show logs (optionally specify service name)"
        echo "  status    Show service status"
        echo "  clean     Remove all containers, volumes, and images"
        echo "  reset-db  Reset database (removes all data)"
        echo "  help      Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0 start"
        echo "  $0 logs backend"
        echo "  $0 reset-db"
        ;;
esac