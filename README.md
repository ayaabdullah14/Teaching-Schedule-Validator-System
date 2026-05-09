# Teaching Schedule Validator

![Language](https://img.shields.io/badge/Language-Bash-4EAA25?style=flat-square&logo=gnu-bash&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS-lightgrey?style=flat-square)
![Status](https://img.shields.io/badge/Status-Complete-success?style=flat-square)

A Bash script that parses and validates a professor's weekly teaching schedule against a defined set of academic compliance rules. Developed as a Systems Programming course project at Birzeit University.

---

## Table of Contents

- [Overview](#overview)
- [Validation Rules](#validation-rules)
- [Input Format](#input-format)
- [Usage](#usage)
- [Output](#output)

---

## Overview

The validator reads a structured schedule file, converts time intervals to minutes for accurate arithmetic, then checks each session against six academic rules. It outputs a per-rule validation result and a final `VALID` / `INVALID` verdict.

---

## Validation Rules

| # | Rule | Requirement |
|---|------|-------------|
| 1 | Teaching Load | Must be between **12 and 18 hours/week** |
| 2 | Office Hours | Must be at least **50% of total teaching load** |
| 3 | Teaching Days | Must span at least **4 different days** |
| 4 | Time Conflicts | **No overlapping sessions** allowed |
| 5 | Consecutive Sessions | **No more than 2** back-to-back teaching sessions |
| 6 | Valid Days | Only `S`, `M`, `T`, `W`, `Th` are permitted |

---

## Input Format

The script expects a plain-text file with one session per line:

```
DAY  HH:MM-HH:MM  TYPE
```

Where `TYPE` is either `T` (Teaching) or `OH` (Office Hours).

**Example (`schedule.txt`):**

```
M   08:00-09:30   T
M   10:00-11:00   OH
T   09:00-10:30   T
W   08:00-09:30   T
W   11:00-12:00   OH
Th  09:00-10:30   T
```

---

## Usage

```bash
# Make the script executable
chmod +x firstProject.sh

# Run with a schedule file
./firstProject.sh schedule.txt
```

---

## Output

The script prints a detailed validation report followed by a final summary:

```
Total Teaching Load : 12.0 hours
Total Office Hours  : 3.0 hours

[Rule 1] Teaching load (12–18h)    : VALID
[Rule 2] Office hours (≥ 50%)      : VALID
[Rule 3] Minimum 4 teaching days   : VALID
[Rule 4] No time conflicts         : VALID
[Rule 5] No consecutive overload   : VALID
[Rule 6] Valid teaching days only  : VALID

============================
Final Result : VALID
============================
```

---

> **Course:** Operating Systems & Shell Scripting — Computer Engineering Department, Birzeit University
