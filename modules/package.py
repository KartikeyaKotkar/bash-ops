#!/usr/bin/env python3

import os
import sys
import json
import subprocess

"""
BASH-Ops Module: package

This module handles the presence of system packages.
It is designed for Debian-based systems (using `apt` and `dpkg`).
"""

# --- State Check --- #

def is_package_installed(package_name):
    """Checks if a package is installed and configured on a Debian-based system."""
    try:
        # Use dpkg-query to check the package status. We don't need the output.
        subprocess.run(
            ["dpkg-query", "-W", "-f='${Status}'", package_name],
            check=True, 
            capture_output=True
        )
        # The command returns 0 if the package is known to dpkg. We parse the status
        # to confirm it is actually installed.
        status = subprocess.check_output(["dpkg-query", "-W", "-f='${Status}'", package_name]).decode('utf-8')
        return 'install ok installed' in status
    except (subprocess.CalledProcessError, FileNotFoundError):
        # If dpkg-query returns a non-zero exit code or the command is not found,
        # we can safely assume the package is not installed.
        return False

# --- Module Actions --- #

def present(params):
    """Ensures a package is present on the system."""
    package_name = params.get("PARAM_NAME")
    # BASH_OPS_CHECK_MODE is passed by the engine.
    check_mode = params.get("BASH_OPS_CHECK_MODE", 'false').lower() == 'true'

    if not package_name:
        return {"success": False, "changed": False, "msg": "Missing required 'name' parameter for package."}

    is_installed = is_package_installed(package_name)

    if is_installed:
        return {"success": True, "changed": False, "msg": f"Package '{package_name}' is already installed."}

    # If we are in check mode, report what would have happened.
    if check_mode:
        return {"success": True, "changed": True, "msg": f"Package '{package_name}' would be installed."}

    # --- Apply Mode: Perform the installation --- #
    try:
        # NOTE: In a more advanced implementation, `apt-get update` should be
        # handled as a separate, explicit resource run once per convergence.
        # Running it for every package is inefficient.
        tui_log("Running apt-get update...")
        subprocess.run(["apt-get", "update"], check=True, capture_output=True)
        
        tui_log(f"Installing package: {package_name}")
        subprocess.run(["apt-get", "install", "-y", package_name], check=True, capture_output=True)
        
        return {"success": True, "changed": True, "msg": f"Package '{package_name}' was successfully installed."}
    except subprocess.CalledProcessError as e:
        return {
            "success": False, 
            "changed": False, 
            "msg": f"Failed to install package '{package_name}'.", 
            "stderr": e.stderr.decode('utf-8', 'ignore')
        }
    except FileNotFoundError:
        return {"success": False, "changed": False, "msg": "'apt-get' command not found. This module requires a Debian-based OS."}


def main():
    """Main entry point for the module."""
    # The BASH-Ops engine passes all parameters as environment variables.
    params = dict(os.environ)

    # For now, this module only supports the 'present' action.
    action = "present"

    if action == "present":
        result = present(params)
    else:
        result = {"success": False, "changed": False, "msg": f"Unknown action: {action}"}

    # All modules must print a single line of JSON to stdout.
    print(json.dumps(result))

if __name__ == "__main__":
    main()
