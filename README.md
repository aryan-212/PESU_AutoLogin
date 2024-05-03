# AutoLogin Script

This repository contains a script designed for automated login into PES-University WIFI.

## Table of Contents
- [Installation](#installation)

## Installation

1. For bash:
   ```bash
   sudo curl -sL https://github.com/aryan-212/PESU_AutoLogin/raw/main/Login.sh -o /usr/local/bin/pesu && sudo chmod +x /usr/local/bin/pesu
  
2. For windows:
   ```powershell
   git clone https://github.com/aryan-212/PESU_AutoLogin.git
   cd PESU_AutoLogin
   ```
   [IMP] Add this in your Powershell userprofile or execute it each time:
   ```powershell  
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   ```

## Usage
1. In linux
```bash
   pesu
```
2. In windows:
```powershell
    .\autoLogin.ps1
```
