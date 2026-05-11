# Installing Superpowers for Devin CLI

This fork includes built-in `.devin/skills/` symlinks so Superpowers works
out-of-the-box when you run `devin` inside this repository.

## Quick Install

### Option 1: Global Install (Recommended)

Install Superpowers skills into your global Devin CLI config so they're
available in **every** project:

```bash
git clone <your-fork-url> superpowers
cd superpowers
./scripts/install-devin.sh --global
```

Done. Now run `devin` anywhere and use `/skills` to verify.

### Option 2: Per-Project Install

Install into a specific project:

```bash
cd /path/to/your-project
/path/to/superpowers/scripts/install-devin.sh --project .
```

Skills will be discovered when you run `devin` from that project.

### Option 3: Use the Built-In Symlinks (No Install)

If you always work from this repo, you don't need to install anything:

```bash
cd superpowers
devin
```

The `.devin/skills/` directory already contains symlinks to all skills.

## Verify Installation

```bash
devin
```

Then type:

```
/skills
```

You should see all Superpowers skills listed (brainstorming, test-driven-development, etc.).

## Uninstall

```bash
./scripts/install-devin.sh --uninstall
```

This removes the symlinks from `~/.config/devin/skills/`.

## How It Works

The install script creates symlinks in Devin CLI's skills search path:

```
~/.config/devin/skills/          # global
or
<your-project>/.devin/skills/    # project-local
    ├── brainstorming -> /path/to/superpowers/skills/brainstorming
    ├── using-superpowers -> /path/to/superpowers/skills/using-superpowers
    └── ...
```

Symlinks keep your skills up to date automatically — just `git pull` the repo.

## Tool Mapping

Devin CLI uses the same tool names as Claude Code for most operations:

| Claude Code | Devin CLI |
|-------------|-----------|
| `Skill` | `/skill-name` (slash command) or `skill` tool |
| `TodoWrite` | `todo_write` |
| `Task` (subagents) | `run_subagent` |
| `Read` | `read` |
| `Write` | `write` |
| `Edit` | `edit` |
| `Bash` | `exec` |

Skills that reference Claude-specific tools should work with Devin CLI with minimal or no adaptation.

## Updating

Pull the latest changes from your fork:

```bash
cd superpowers
git pull
```

The symlinks automatically point to the updated content. No re-install needed.

## Troubleshooting

### Skills not found

1. Make sure you are running `devin` from a directory that has `.devin/skills/` (project) or that skills are installed globally
2. Check that symlinks exist:
   ```bash
   ls -la ~/.config/devin/skills/
   ```
3. Use the `/skills` slash command to list discovered skills

### install-devin.sh fails with "Skills source not found"

Run the script from the repo root, or pass `--repo /path/to/superpowers`:

```bash
./scripts/install-devin.sh --global --repo /path/to/superpowers
```

### Windows

On Windows (Git Bash, WSL, MSYS), the script works as-is. If using native Windows without bash, manually copy or symlink the `skills/` directories into `%APPDATA%\devin\skills\`.

## For More Help

- Devin CLI docs: `devin --help` or visit https://cli.devin.ai/docs
- Superpowers docs: see `skills/using-superpowers/SKILL.md`
