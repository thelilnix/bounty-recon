# bounty-recon
Just a (not so)simple bash script for reconnaissance. Recommended for local usage, use @nahamsec 's script for remote usage.

![License: MIT](https://img.shields.io/badge/License-MIT-red)
[![Follow me](https://img.shields.io/github/followers/ebsa491?label=Follow%20me&style=social)](https://github.com/ebsa491)

## Table of contents
* [Requirements](#requirements)
* [Installation](#installation)
* [Usage](#usage)
* [Contributing](#contributing)
* [TODO](#todo)
* [Other](#other)

## Requirements
* Sublist3r
* crt.sh
* waybackurls
* dirsearch
* https://github.com/sathishshan/Zone-transfer
* DIG
* aha (for coloring html output)
* curl
* nmap
* JSFScan.sh
* deduplicate
* gf
* Dalfox
* aquatone
* whichCDN (SamEbison fork) (https://github.com/ebsa491/whichCDN.git)
* unfurl
* httprobe
* xdg-open
* massdns (not required)
* Asnlookup (not required)
* virtual-host-discovery (not required)

## Installation

run `install.sh` (debian-based)
Change the script settings too

## Usage

```shell
./create.sh YOUR_TARGET_NAME
cd YOUR_TARGET_NAME
(edit scope.txt)
./recon.sh YOUR_TOOLS_PATH_WITHOUT_SLASH
```

## Contributing

I will be glad! Open an issue first or work on your assigned issue.

## TODO

- [ ] install.sh
- [ ] out of scope

## Other

Nothing more! Just pay attention to [`LICENSE`](./LICENSE).
