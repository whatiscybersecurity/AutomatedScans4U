

# Automating Scans 4 U

**Automating Scans 4 U** is a simple Bash script that helps automate vulnerability scanning using [naabu](https://github.com/projectdiscovery/naabu) and [nuclei](https://github.com/projectdiscovery/nuclei). The script interactively prompts you to enter domains or IP addresses, validates them (ensuring domains resolve via DNS), and then runs the following workflow:

1. **Tool Installation Check:**  
   Verifies if `naabu` and `nuclei` are installed. If not, the script installs them using Go.

2. **Target Validation:**  
   - For domains: uses `dig` to check if they resolve to an IP.
   - For IP addresses: assumes they are valid.

3. **Scanning:**  
   - Runs naabu on the validated targets.
   - Pipes naabu’s output into nuclei for vulnerability scanning.

4. **Output:**  
   Saves the results to text files for later review.

---

## Features

- **Interactive Input:** Enter domains or IP addresses as a space-separated list.
- **DNS Resolution:** Validates domains using `dig` to ensure they resolve.
- **Automated Tool Installation:** Automatically installs `naabu` and `nuclei` if missing.
- **Integrated Scanning Workflow:** Runs naabu to detect open ports/hosts and feeds its output to nuclei for further scanning.
- **Output Files:** Results are saved in `valid_targets.txt`, `naabu_output.txt`, and `nuclei_results.txt`.

---

## Prerequisites

- **Bash:** This script is written in Bash.
- **Go:** Required for installing or updating `naabu` and `nuclei`.
- **dig:** Provided by the `dnsutils` package on Debian/Ubuntu.
- **Environment:** Tested on WSL (Windows 11) and Linux.
- **PATH Configuration:** Ensure `$HOME/go/bin` is in your PATH (e.g., by adding `export PATH=$PATH:$HOME/go/bin` to your `~/.bashrc`).

---

## Installation

1. **Clone or Download the Repository:**

   ```bash
   git clone https://github.com/yourusername/automating-scans-4u.git
   cd automating-scans-4u
   ```

2. **Make the Script Executable:**

   ```bash
   chmod +x automate_scans.sh
   ```

---

## Usage

Run the script and follow the on-screen prompts:

```bash
./automate_scans.sh
```

The script will:

1. Check for `naabu` and `nuclei` (installing them via Go if they aren’t found).
2. Prompt you to enter the domains or IP addresses to scan (space-separated).
3. Validate each target:
   - If an entry is an IP address, it is accepted.
   - If it is a domain, it is resolved with `dig`.
4. Save the valid targets in `valid_targets.txt`.
5. Run naabu on the valid targets and save the output to `naabu_output.txt`.
6. Pipe naabu’s output into nuclei for a vulnerability scan, saving the results in `nuclei_results.txt`.

---

## Updating Tools

- **Updating nuclei (if installed via Go):**

  ```bash
  go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
  ```

- **If installed via Homebrew (macOS/Linux):**

  ```bash
  brew upgrade nuclei
  ```

- **Updating nuclei templates:**

  ```bash
  nuclei -update-templates
  ```

---

## Troubleshooting

- **No Valid DNS Entries:**  
  If the script outputs:
  
  ```
  site.com did not resolve.
  [-] No valid DNS entries found. Exiting.
  ```
  
  Make sure the domain is correct and has a valid DNS A record (test with `dig +short site.com`).

- **Tool Not Found Errors:**  
  Ensure Go is installed and that `$HOME/go/bin` is in your PATH.

---

## Contributing

Contributions are welcome! If you have suggestions or improvements, please fork this repository and submit a pull request. For issues or questions, open an issue on GitHub.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Disclaimer

This script is provided "as-is", without warranty of any kind. Use it at your own risk. Always test in a controlled environment before using on production systems.

---

Happy Scanning!  
*Automating Scans 4 U Team*

---

You can save this content as `README.md` in your project folder.
