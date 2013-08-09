#!/bin/sh
set -e

xctool -workspace "Stand for Something" -scheme "Stand for Something" build test
