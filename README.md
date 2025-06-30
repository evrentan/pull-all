# 🌀 pull-all

**pull-all** is a lightweight and configurable Bash CLI tool that recursively finds and pulls all Git repositories under a specified directory. It automatically switches to the default branch and supports persistent default directory settings via a local config file.

---

## 🚀 Features

- 🔍 Recursively scans for Git repositories
- 🔁 Auto-switches to the default branch (e.g. `main`, `master`)
- 💾 Configurable default directory using `~/.pullallrc`
- ✅ Works with macOS/Linux (and supports Homebrew install)
- 📦 Simple to install and run from anywhere

---

## 🛠 Installation

### Option 1: Using Homebrew (Recommended)

```bash
brew tap evrentan/pull-all-brew
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
pull-all set-default ~/Work/Repos   # Sets ~/Work/Repos as default
pull-all get-default                # Displays the current default
pull-all help                       # Shows help message
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
  pull-all [directory]           Pull all Git repos in given directory or default
  pull-all run [directory]       (Same as above)
  pull-all set-default <dir>     Set default directory persistently
  pull-all get-default           Show current default directory
  pull-all help                  Show this help message

Examples:
  pull-all
  pull-all ~/projects
  pull-all set-default ~/code
  pull-all get-default
```

---

## ⚖️ License

MIT © [Evren Tan](https://github.com/evrentan)

---

## 🤝 Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change or improve.
