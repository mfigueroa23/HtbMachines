# HTB Machines

A command-line tool to search and filter [HackTheBox](https://www.hackthebox.com) machines by name, IP, difficulty, operating system, skills, and certification paths. Useful for pentesters and CTF players who want to find machines aligned with their practice goals.

## Requirements

- `js-beautify` — for formatting the downloaded bundle
- `sponge` (from `moreutils`) — for in-place file editing

**macOS:**
```bash
npm install -g js-beautify
brew install moreutils
```

**Debian/Ubuntu:**
```bash
npm install -g js-beautify
apt install moreutils
```

## Setup

```bash
git clone https://github.com/mfigueroa23/HtbMachines.git
cd HtbMachines
chmod +x searchMachines.sh
./searchMachines.sh -u   # download the machine database
```

## Usage

```
./searchMachines.sh [options]
```

| Flag | Description |
|------|-------------|
| `-m <name>` | Search machine by name |
| `-i <ip>` | Search machine by IP address |
| `-y <name>` | Get YouTube walkthrough link for a machine |
| `-d <1-4>` | Filter by difficulty: 1=Easy, 2=Medium, 3=Hard, 4=Insane |
| `-s <1-2>` | Filter by OS: 1=Linux, 2=Windows |
| `-k <skill>` | Filter by skill/topic (e.g. `SMB`, `SQLi`) |
| `-c <1-11>` | Filter by certification path (run `-c 0` to list options) |
| `-u` | Update machine database from remote source |
| `-h` | Show help panel |

Flags can be combined. For example:

```bash
# All easy Linux machines
./searchMachines.sh -d 1 -s 1

# OSCP-relevant machines on Linux
./searchMachines.sh -c 6 -s 1

# Machines tagged with a specific skill
./searchMachines.sh -k "Buffer Overflow"
```

## Certifications (`-c`)

| # | Certification |
|---|---------------|
| 1 | eCPPTv2 |
| 2 | eCPTXv2 |
| 3 | eJPT |
| 4 | eWPT |
| 5 | eWPTXv2 |
| 6 | OSCP |
| 7 | OSWE |
| 8 | OSEP |
| 9 | OSED |
| 10 | Active Directory |
| 11 | Buffer Overflow |

## Data Source

Machine data is pulled from [htbmachines.github.io](https://htbmachines.github.io). The `-u` flag downloads the latest `bundle.js` and only applies the update if the MD5 hash differs from the local copy.
