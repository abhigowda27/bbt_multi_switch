# BBTML

BBTML is a Flutter-based mobile application for managing and controlling smart switch devices.

## 📱 Overview

BBTML provides a centralized interface to:

- Manage smart switch devices
- Configure routers
- Control individual switches
- Control multi-switch devices
- Control fan devices
- Create and manage switch groups
- Control all devices within a group
- Monitor device status
- Handle device ON/OFF operations
- Display API success and failure feedback
- Provide animated and responsive device controls

---

## ✨ Features

### 🔌 Switch Management

- View available switches
- View switch details
- Turn individual switches ON/OFF
- Display current switch status
- Restore previous state when API calls fail
- Support multiple device types

### 🌀 Fan Control

Fan devices support:

- Fan ON/OFF control
- Fan speed control
- Dynamic fan status mapping
- Device-specific API commands

### 🔀 Multi-Switch Support

BBTML supports multi-switch devices where a single physical device contains multiple child switches.

```text
Parent Device
 ├── Child Switch 1
 ├── Child Switch 2
 ├── Child Switch 3
 └── Child Switch 4