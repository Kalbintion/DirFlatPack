# DirFlatPack
A Windows batch script designed to flatten out a directory structure by creating symbolic links (symlinks) to each file.

# Supported OSes
| OS | Version | Supported |
|----|---------|-----------|
| Win | 95 | Unknown |
| Win | 98 | Unknown |
| Win | ME | Unknown |
| Win | XP | Unknown |
| Win | 7 | Yes |
| Win | 8 | Yes |
| Win | 10 | Yes |
| Win | 11 | Yes|

# Usage
The batch file usage information can always be shown at any time without visiting this page by issueing a `/?`, `-?`, or `--help` flag to the batch program. A copy of this output in tabular form is provided below.

| Flag           | Default | Meaning |
|----------------|---------|---------|
| /?, -?, --help |         | Shows this usage information |
| /d path, -d path, --from path | %~dp0 | The path to get all the files from. Uses the directory path provided. If left out, assumes current working directory |
| /o path, -o path, --to path | %~dp0 | The path to output all the symlinks to. Uses the directory path provided. If left out, assumes current working directory |
| /l filter, -l filter, --list filter |  | The filter used listing files. If not set, will get all files. |
| /r, -r, --remove | | Removes existing symlinks from output path before creating new ones |
| /fd flags, -fd flags, --dirflags flags | /A-D-L /B /S | Overrides flags for the DIR command. |
| /fs flags, -fs flags, --symflags flags | | Overrides flags for the MKLINK command |
| /il chars, -il chars, --illegal chars | \/:?" | Overrides default characters that are not suitable for filenames |
| /v, -v, --verbose | | If set, shows more detail on what it's doing |
