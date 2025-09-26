# BASH-Ops: A Declarative, Interactive Infrastructure Control Plane

BASH-Ops is a configuration management tool that brings the power of declarative, idempotent infrastructure management directly into your terminal, using the tools you already have: **BASH**, **SSH**, and **Python**.

It provides an agentless, interactive TUI to visualize configuration drift and apply changes with confidence, blending the philosophy of modern tools like Ansible and Terraform with the simplicity and ubiquity of the shell.

```
* State Diff *
> [x] [NEEDS CHANGE] localhost: install_nginx
  [ ] [NEEDS CHANGE] localhost: configure_nginx
  [ ] [NEEDS CHANGE] localhost: start_nginx

* Execution Log *                     * Help *
[15:32:01] Check finished.           j/k,↑/↓: Navigate | space: Stage/Unstage
[15:32:05] Applying 1 staged change… a: Apply Staged | r: Refresh | q: Quit
```

This project is a functional implementation of the core design, including an interactive TUI, dependency management, and dynamic inventories, as described in the detailed [DESIGN.md](DESIGN.md) document.

## Core Principles

*   **Agentless Architecture:** No daemons or custom software required on managed nodes. All communication happens over standard SSH.
*   **Declarative Configuration:** Define the *desired state* of your system in simple YAML files. Say *what* you want, not *how* to do it.
*   **Interactive-First:** A full Terminal User Interface (TUI) provides a real-time, interactive feedback loop for managing infrastructure.
*   **Minimal Dependencies:** The core engine is pure BASH. Python is used strategically for specialized tasks where it offers a clear advantage (e.g., YAML parsing).

## Getting Started

### Prerequisites

*   **BASH** (v4.0+ recommended)
*   **Python 3** & **pip**
*   **OpenSSH** (`ssh` and `scp` clients).
*   **Key-based SSH access** to target hosts (including `localhost` for testing) to avoid password prompts.

### Installation

1.  Clone this repository.
2.  Install the required Python packages:

    ```sh
    pip install -r requirements.txt
    ```

## Usage

Run the `bash-ops` script with an inventory file and a playbook file to launch the interactive TUI.

```sh
# Make the script executable
chmod +x ./bash-ops

# Run BASH-Ops!
./bash-ops inventory.ini play.yml
```

### Interactive Controls

| Key(s)              | Action                                      |
| ------------------- | ------------------------------------------- |
| `j`, `k`, `↑`, `↓`    | Navigate the list of resource states.       |
| `space`             | Stage or unstage the selected change.       |
| `a`                 | Apply all currently staged changes.         |
| `r`                 | Refresh the state of all resources.         |
| `q`                 | Quit the application.                       |

## Features

### State Diff & Convergence

The main view shows the "State Diff"—a list of all resources and their current status. Use the `space` key to stage the changes you want to apply, then press `a` to converge only those items.

*   `[OK]` items are already in the desired state.
*   `[NEEDS CHANGE]` items have drifted from the playbook's definition.

### Dependency Management

The engine understands `requires` clauses in your playbook. It builds a dependency graph and uses a topological sort to determine the correct execution order, ensuring that `service.running` doesn't execute until the `file.managed` configuration is in place.

```yaml
# from play.yml
- name: start_nginx
  type: service.running
  params: { name: nginx }
  requires: # This won't run until configure_nginx is OK.
    - configure_nginx
```

### Dynamic & Static Inventory

BASH-Ops supports both static INI files and dynamic, executable inventory scripts. 

*   **Static:** A simple INI format for defining hosts and variables.
*   **Dynamic:** If your inventory file is executable, BASH-Ops will run it and parse the JSON output, allowing you to source hosts from cloud APIs or other tools.

## Project Structure

```
.
├── bash-ops          # The main BASH engine and TUI script.
├── DESIGN.md         # The detailed architectural blueprint for the project.
├── inventory.ini     # A sample static inventory file.
├── play.yml          # A sample playbook defining the desired state.
├── requirements.txt  # Python dependencies.
├── modules/          # Directory for self-contained, idempotent modules.
│   └── package.py    # A Python module to manage system packages.
└── utils/            # Directory for helper scripts.
    ├── parser.py     # A Python script to parse YAML playbooks.
    └── tui.sh        # The pure-BASH TUI rendering library.
```
