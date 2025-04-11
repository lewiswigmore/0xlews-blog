+++
title = 'Bash Scripting Cheat Sheet: A Practical Guide'
date = 2025-02-03T13:30:00+01:00
draft = false
tags = ["linux", "bash", "scripting", "cli"]
categories = ["Docs", "CLI"]
description = "A practical, hands-on guide to Bash scripting with a couple everyday examples you might actually use."
+++

# Bash Scripting Cheat Sheet: A Practical Guide

I found myself doing the same tasks over and over again at work, and decided it was time to properly learn some bash scripting. Here's my personal cheat sheet with the commands and patterns I actually use.

## The Basics: Variables and Output

The building blocks of any script start with variables and displaying information. Nothing fancy, but you'll use these constantly.

### Defining a Variable

```bash
name="Lewis"
```

Pro tip: Bash is extremely picky about spaces. `name = "Lewis"` will break your script!

### Displaying a Variable

```bash
echo $name   # Outputs: Lewis
```

If you see plain text of your variable name in the output, you probably forgot the `$` prefix to the variable.

### Capturing Command Output in a Variable

This one lets you grab the output of any command and store it for later use:

```bash
current_date=$(date)
echo "Today is $current_date"

# Another useful one for scripts
script_dir=$(dirname "$(readlink -f "$0")")
echo "This script is running from $script_dir"
```

## Conditional Statements and Flow Control

Using conditional statements for making decisions. 

### Using if-else Conditions

```bash
if [ "$name" == "Lewis" ]; then
    echo "Hello, Lewis!"
else
    echo "Hello, stranger!"
fi
```

For example, you can use this pattern for checking if files exist before trying to process them:

```bash
if [ -f "config.json" ]; then
    echo "Found config file, proceeding..."
else
    echo "Error: config.json not found!"
    exit 1
fi
```

## Loop Constructs: Automating Repetition

Loops are where bash scripting really gets good. You can use them to process batches of files or repeat tasks with slight variations.

### Using a for Loop

```bash
for i in {1..5}; do
    echo "Iteration $i"
done
```

A real-world example I use frequently:

```bash
for file in *.log; do
    echo "Processing $file..."
    grep "ERROR" "$file" >> all_errors.txt
done
```

### Using a while Loop

```bash
count=1
while [ $count -le 5 ]; do
    echo "Iteration $count"
    ((count++))
done
```

## Functions: Modular Scripting

For any script longer than 20 lines, it's good to break things into functions. It keeps everything organised and lets you reuse logic.

### Defining a Function

```bash
function greet() {
    echo "Hello, $1!"
}
```

### Calling a Function

```bash
greet "Lewis"   # Outputs: Hello, Lewis!
```

## Pipelines and Redirection

Combining commands together to process data is incredibly useful.

### Using a Pipeline

```bash
ls -l | grep "txt"  # Lists only files containing "txt" in the name
```

A more complex example I use to find large files:

```bash
find . -type f -name "*.log" | xargs du -h | sort -hr | head -10
```

### Redirecting Output to a File

```bash
echo "This is a test" > output.txt   # Creates or overwrites file
echo "more data" >> output.txt   # Appends to file
```

I use redirection to create log files for my scripts:

```bash
./my_process > process.log 2>&1   # Captures both standard output and errors
```

## Advanced Constructs Worth Learning (I'm still not good at)

### Using a case Statement (cleaner than multiple if-else)

```bash
case $1 in
    start)
        echo "Starting the service..."
        service_start
        ;;
    stop)
        echo "Stopping the service..."
        service_stop
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
```

### Using Arrays

Arrays are perfect when you need to work with collections of items:

```bash
colors=("red" "green" "blue")
echo ${colors[0]}      # Output: red
echo ${colors[@]}      # Output: red green blue
echo ${#colors[@]}     # Output: 3 (array length)

# Looping through an array
for color in "${colors[@]}"; do
    echo "Color: $color"
done
```

## A Practical Example: Auth log analysis

Here's a simple but practical script I use for basic security monitoring to detect potential brute force attacks in authentication logs:

```bash
#!/bin/bash

# A threshold script to detect potential brute force attacks from auth.log
# Usage: ./detect_brute_force.sh /var/log/auth.log

function check_file() {
    if [ ! -f "$1" ]; then
        echo "Error: Log file $1 does not exist!"
        exit 1
    fi
}

function analyse_auth_log() {
    local log_file="$1"
    local threshold="$2"
    
    echo "=== Analysing $log_file for potential brute force attacks ==="
    echo "Threshold: $threshold failed attempts from a single IP"
    echo ""
    
    # Find all failed password attempts and count occurrences by IP
    echo "Top potentially malicious IPs:"
    grep "Failed password" "$log_file" | grep -oE "from ([0-9]{1,3}\.){3}[0-9]{1,3}" | cut -d ' ' -f 2 | sort | uniq -c | sort -nr | head -10
    
    echo ""
    echo "=== Detailed analysis of suspicious IPs ==="
    
    # Get IPs with more failed attempts than the threshold
    suspicious_ips=$(grep "Failed password" "$log_file" | grep -oE "from ([0-9]{1,3}\.){3}[0-9]{1,3}" | cut -d ' ' -f 2 | sort | uniq -c | sort -nr | awk -v threshold="$threshold" '$1 > threshold {print $2}')
    
    if [ -z "$suspicious_ips" ]; then
        echo "No IPs exceeded the threshold of $threshold failed attempts."
        return
    fi
    
    # For each suspicious IP, show details of attempts
    for ip in $suspicious_ips; do
        echo "IP: $ip"
        echo "Target usernames:"
        grep "Failed password" "$log_file" | grep "$ip" | grep -oE "for [a-zA-Z0-9_]+ from" | cut -d ' ' -f 2 | sort | uniq -c | sort -nr
        echo "Timestamps of recent attempts:"
        grep "Failed password" "$log_file" | grep "$ip" | awk '{print $1, $2, $3}' | tail -5
        echo "---"
    done
}

# main script execution would start here
if [ $# -lt 1 ]; then
    echo "Usage: $0 <auth_log_file> [threshold]"
    echo "Example: $0 /var/log/auth.log 10"
    exit 1
fi

LOG_FILE="$1"
THRESHOLD=${2:-5} # default threshold of 5 failed attempts

check_file "$LOG_FILE"
analyse_auth_log "$LOG_FILE" "$THRESHOLD"

echo ""
echo "For forensic investigation, you might want to check these files as well:"
echo "- /var/log/btmp (Failed login attempts)"
echo "- /var/log/wtmp (Login history)"
echo "- /var/log/lastlog (Last login for each user)"
echo ""
echo "Use commands like 'last' or 'lastb' to analyse those binary logs easily."
```

This script helps me analyse authentication logs to identify potential brute force attacks. It:

1. Counts failed password attempts by IP address
2. Highlights IPs that exceed a threshold of failed attempts
3. Lists the usernames targeted by each suspicious IP
4. Shows timestamps of recent attempts

I've used more simple versions of this during forensic analysis to quickly identify compromised accounts and attacking IPs.

You can run it against standard Linux auth logs like `/var/log/auth.log` or against exported logs during a forensic investigation. If you're working with `btmp` or `wtmp` logs, you'd typically use tools like `last` or `lastb` to first convert them to text, then pipe them into similar analysis scripts.

---

I've found that the best way to learn bash scripting is to start with small, useful scripts that solve real problems.