#!/usr/bin/env bash

# Scan for available WiFi networks first
nmcli device wifi rescan

# Wait a moment for scan to complete
sleep 1

# Launch nmtui
nmtui