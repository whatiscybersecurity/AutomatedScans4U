#!/bin/bash
# ------------------------------------------------------------------
# Automating Scans 4 U
# A simple script to check for and install nabuu and nuclei,
# prompt the user for domains or IP addresses,
# validate each target, and then run nabuu followed by nuclei scans.
# ------------------------------------------------------------------

# Display custom ASCII header
cat << "EOF"
                            ____
        ____....----''''````    |.
,'''````            ____....----; '.
| __....----''''````         .-.`'. '.
|.-.                .....    | |   '. '.
`| |        ..:::::::::::::::| |   .-;. |
 | |`'-;-::::::::::::::::::::| |,,.| |-='
 | |   | ::::::::::::::::::::| |   | |
 | |   | :::::::::::::::;;;;;| |   | |
 | |   | :::::::::Made by::::| |   | |
 | |   | ::::github.com/what:| |   | |
 | |   | :::iscybersecurity::| |   | |
 | |   | :::+++++++++++++++++| |   | |
 | |   | |;++++++++++++++++++| |   | |
 | |   | | ;++++++++++++++++;| |   | |
 | |   | |  ;++++++++++++++;.| |   | |
 | |   | |   :++++++++++++:  | |   | |
 | |   | |    .:++++++++;.   | |   | |
 | |   | |       .:;+:..     | |   | |
 | |   | |         ;;        | |   | |
 | |   | |      .,:+;:,.     | |   | |
 | |   | |    .::::;+::::,   | |   | |
 | |   | |   ::::::;;::::::. | |   | |
 | |   | |  :::::::+;:::::::.| |   | |
 | |   | | ::::::::;;::::::::| |   | |
 | |   | |:::::::::+:::::::::| |   | |
 | |   | |:::::::::+:::::::::| |   | |
 | |   | ::::::::;+++;:::::::| |   | |
 | |   | :::::::;+++++;::::::| |   | |
 | |   | ::::::;+++++++;:::::| |   | |
 | |   |.:::::;+++++++++;::::| |   | |
 | | ,`':::::;+++++++++++;:::| |'"-| |-..
 | |'   ::::;+++++++++++++;::| |   '-' ,|
 | |    ::::;++++++++++++++;:| |     .' |
,;-'_   `-._===++++++++++_.-'| |   .'  .'
|    ````'''----....___-'    '-' .'  .'
'---....____           ````'''--;  ,'
            ````''''----....____|.'

      Automating Scans 4 U
EOF
echo
echo "Starting Automated Scans..."
echo "-------------------------------------"

# Function to install a Go-based tool if not installed
install_if_missing() {
  local cmd="$1"
  local install_cmd="$2"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "[*] $cmd not found. Installing $cmd..."
    eval "$install_cmd"
    echo "[!] Make sure that \$HOME/go/bin is in your PATH."
  else
    echo "[+] $cmd is already installed."
  fi
}

# Check if nabuu is installed; if not, install it via Go
install_if_missing "naabu" 'go install -v github.com/projectdiscovery/naabu/cmd/naabu@latest'

# Check if nuclei is installed; if not, install it via Go
install_if_missing "nuclei" 'go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest'

echo "-------------------------------------"

# Prompt the user to enter target domains or IP addresses (space-separated)
read -p "Enter the domains or IP addresses to scan (separated by space): " input_targets
IFS=' ' read -r -a targets <<< "$input_targets"

# Validate targets and store valid ones in a temporary file
valid_file="valid_targets.txt"
: > "$valid_file"   # Clear or create the file

echo "[*] Validating targets..."
for target in "${targets[@]}"; do
  # Trim any extra whitespace
  target=$(echo "$target" | xargs)
  [ -z "$target" ] && continue

  # If target is an IPv4 address (using a simple regex), assume it's valid
  if [[ $target =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "[+] $target is a valid IPv4 address."
    echo "$target" >> "$valid_file"
  else
    # Otherwise, assume it's a domain; attempt to resolve it
    ip=$(dig +short "$target" | head -n 1)
    if [ -n "$ip" ]; then
      echo "[+] $target resolves to $ip"
      echo "$target" >> "$valid_file"
    else
      echo "[-] $target did not resolve; skipping."
    fi
  fi
done

if [ ! -s "$valid_file" ]; then
  echo "[-] No valid targets found. Exiting."
  exit 1
fi
echo "[*] Valid targets saved to $valid_file."
echo "-------------------------------------"

# Run nabuu on valid targets
echo "[*] Running nabuu..."
nabuu_output="naabu_output.txt"
cat "$valid_file" | naabu -o "$nabuu_output"
echo "[*] naabu scanning complete. Results saved to $naabu_output."
echo "-------------------------------------"

# Run nuclei using the output from nabuu as targets
echo "[*] Running nuclei..."
nuclei_output="nuclei_results.txt"
cat "$nabuu_output" | nuclei -o "$nuclei_output"
echo "[*] nuclei scanning complete. Results saved to $nuclei_output."
echo "-------------------------------------"

echo "Automated Scans Completed!"
