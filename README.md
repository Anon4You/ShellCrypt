ShellCrypt 🔐

Professional code obfuscation tool for Bash and Python scripts.

![Shellcrypt](Shellcrypt.jpg)

Features

· Dual Language: Obfuscate/decode Bash & Python scripts
· Auto-detection: Smart file type recognition
· Clean Output: Automatic file naming with proper headers
· Termux Support: Available on Android via TermuxVoid repository

## Installation

### Method 1: Manual Installation

```bash
git clone https://github.com/Anon4You/ShellCrypt.git
cd ShellCrypt
chmod +x shellcrypt.sh install_dependencies.sh
./install_dependencies.sh
```

### Method 2: Using TermuxVoid Repository

If you have added the **TermuxVoid Repository**, you can install the tool using `apt`:

1. Add the TermuxVoid Repository: [TermuxVoid Repository](https://github.com/termuxvoid)
2. Install the shellcrypt tool:
   ```bash
   apt install shellcrypt
   ```

Usage

```bash
# Obfuscate (creates script_ob.sh)
./shellcrypt.sh script.sh

# Decode (creates obfuscated_dc.py)  
./shellcrypt.sh -d obfuscated.py

# Custom output filename
./shellcrypt.sh script.py -O protected.py
```

Dependencies

· bash-obfuscate (Node.js)
· emojify (Python)
· figlet (required for banner)

---

Note: For basic obfuscation purposes. Always verify decoded scripts before execution.

MIT License • https://github.com/Anon4You/ShellCrypt