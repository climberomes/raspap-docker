#!/bin/bash
# Docker cleanup script

echo "Docker disk usage before cleanup:"
docker system df

echo "Cleaning up stopped containers..."
docker container prune -f

echo "Removing unused images..."
docker image prune -a -f

echo "Cleaning builder cache..."
docker builder prune -f

echo "Removing everything else (including unused volumes)..."
docker system prune -a --volumes -f

echo "Docker disk usage after cleanup:"
docker system df