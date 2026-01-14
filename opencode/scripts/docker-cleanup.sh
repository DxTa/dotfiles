#!/bin/bash
# Docker Cleanup Script
# Removes unused images, stopped containers, and build cache older than 48 hours
# Runs twice daily via cron (10 AM and 10 PM)

set -euo pipefail

LOG_DIR="$HOME/.local/log"
LOG_FILE="$LOG_DIR/docker-cleanup.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Ensure log directory exists
mkdir -p "$LOG_DIR"

{
    echo "=========================================="
    echo "Docker Cleanup Started: $TIMESTAMP"
    echo "=========================================="
    
    echo ""
    echo "[1/3] Pruning stopped containers (>48h)..."
    docker container prune -f --filter "until=48h" 2>&1
    
    echo ""
    echo "[2/3] Pruning unused images (>48h)..."
    docker image prune -af --filter "until=48h" 2>&1
    
    echo ""
    echo "[3/3] Pruning build cache (>48h)..."
    docker builder prune -f --filter "until=48h" 2>&1
    
    echo ""
    echo "Docker Cleanup Completed: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
} >> "$LOG_FILE" 2>&1
