# BitLocker PIN Management Utility 🔐

This PowerShell-based utility provides a secure and user-friendly interface for resetting the BitLocker TPM+PIN protector on Windows systems.

## 🚀 Features

- Fully graphical interface using Windows Forms
- Supports Turkish characters and instructions
- Input validation (length, empty, mismatch)
- Automatically resizes windows based on content
- Clean, modern UI with Unicode icon support
- Prevents success message when PIN input is invalid

## 🛠️ How It Works

1. Displays an informational screen about valid PIN rules.
2. Prompts the user to enter and confirm a new PIN.
3. Validates the PIN inputs:
   - Must be between 6–20 characters
   - Cannot be empty
   - Both entries must match
4. Removes the existing TPM+PIN protector (if any).
5. Adds a new TPM+PIN protector using the given PIN.
6. Shows a success or error message based on the outcome.

## 📋 Requirements

- Windows with BitLocker enabled on drive `C:`
- TPM (Trusted Platform Module) must be available
- Run as Administrator (required for BitLocker commands)
- PowerShell 5.1+ (built-in on Windows 10+)

## ⚙️ Usage

1. Save the script as `BitLockerPinManager.ps1`.
2. Open **PowerShell as Administrator**.
3. Allow temporary execution (if needed):

   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
