#!/usr/bin/env python3

import sys
import yaml
import base64

"""
Parses the BASH-Ops YAML playbook from stdin and converts it into a simplified,
line-oriented format that is easily and safely parsable by the BASH engine.

Output Format:
- Each resource is separated by a "---" line.
- Each key-value pair is printed as `KEY=value`.
- To handle multi-line strings safely, values containing newlines are
  base64 encoded and output as `KEY_B64=encoded_value`.
"""

try:
    data = yaml.safe_load(sys.stdin)
    if "resources" in data:
        for i, resource in enumerate(data["resources"]):
            if i > 0:
                print("---")
            
            for key, value in resource.items():
                if key == "params":
                    for p_key, p_value in value.items():
                        # Safely handle multi-line and special characters in params
                        if isinstance(p_value, str) and '\n' in p_value:
                            encoded_value = base64.b64encode(p_value.encode('utf-8')).decode('utf-8')
                            print(f"PARAM_{p_key.upper()}_B64={encoded_value}")
                        else:
                            print(f"PARAM_{p_key.upper()}={p_value}")
                elif key == "requires":
                    print(f"REQUIRES={','.join(value)}")
                else:
                    print(f"{key.upper()}={value}")

except yaml.YAMLError as e:
    print(f"Error parsing YAML: {e}", file=sys.stderr)
    sys.exit(1)
except Exception as e:
    print(f"An unexpected error occurred: {e}", file=sys.stderr)
    sys.exit(1)
