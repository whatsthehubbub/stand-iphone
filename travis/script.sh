#!/bin/sh
set -e

# Test update

xctool -workspace "Stand for Something" -scheme "Stand for Something" build test
