# 🌀 pull-all

**pull-all** is a lightweight and configurable Bash CLI tool that recursively finds and pulls all Git repositories under a specified directory. It automatically switches to the default branch and supports persistent default directory settings via a local config file.

---

## 🚀 Features

- 🔍 Recursively scans for Git repositories
- 🔁 Auto-switches to the default branch (e.g. `main`, `master`)
- 💾 Configurable default directory using `~/.pullallrc`
- 🚫 Exclude specific directories from scanning
- ✅ Works with macOS/Linux (and supports Homebrew install)
- 📦 Simple to install and run from anywhere
- 🧵 Supports parallel execution for faster updates

---

## 🛠 Installation

### Option 1: Using Homebrew (Recommended)

```bash
brew tap evrentan/pull-all
brew install pull-all
```

### Option 2: Manual Installation

Clone the repo and move the script into your PATH:

```bash
git clone https://github.com/evrentan/pull-all.git
cd pull-all
chmod +x pull-all.sh
mv pull-all.sh /usr/local/bin/pull-all  # move script to a folder in your PATH (choose this or the next one)
ln -s pull-all.sh /usr/local/bin/pull-all # instead of moving, create a symlink (choose this or the previous one)
pull-all help
```

---

## 🧪 Usage

```bash
pull-all [command or directory]
```

### ✅ Examples

```bash
pull-all                            # Uses default directory
pull-all ~/Projects                 # Pulls all repos in ~/Projects
pull-all run .                      # Pulls all repos in current directory
pull-all --exclude node_modules     # Pulls all repos except those in node_modules
pull-all --exclude vendor,dist ~/code # Pulls all repos except those in vendor or dist
pull-all set-default ~/Work/Repos   # Sets ~/Work/Repos as default
pull-all get-default                # Displays the current default
pull-all help                       # Shows help message
pull-all -p                         # Pulls all repos in parallel
```

---

## 📁 Configuration

The default directory is stored in a local config file:

```
~/.pullallrc
```

This file is automatically created or updated when you use:

```bash
pull-all set-default <directory>
```

You can manually edit it too. It should contain:

```bash
DEFAULT_DIR="/your/folder/path"
```

---

## 📄 Help Output

```bash
pull-all help
```

Output:

```
pull-all 🌀

Usage:
  pull-all [directory]                     Pull all Git repos in given directory or default
  pull-all run [directory]                 (Same as above)
  pull-all --exclude dir1,dir2 [directory] Pull all Git repos except specified directories
  pull-all -p|--parallel [dir]            Pull all repos in parallel
  pull-all set-default <dir>              Set default directory persistently
  pull-all get-default                    Show current default directory
  pull-all help                           Show this help message


Note: The -p or --parallel flag can be placed anywhere in the command

Examples:
  pull-all
  pull-all ~/projects
  pull-all --exclude node_modules,vendor ~/code
  pull-all -p ~/projects
  pull-all ~/projects -p
  pull-all --parallel
  pull-all run -p ~/projects
  pull-all run ~/projects --parallel
  pull-all set-default ~/code
  pull-all get-default
```

---

## ⚖️ License

MIT © [Evren Tan](https://github.com/evrentan)

---

## 🤝 Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change or improve.
