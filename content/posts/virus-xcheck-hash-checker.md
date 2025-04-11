+++
title = 'Virus.xcheck: A Tool for Finding Malware Samples'
date = 2024-12-04T11:00:00+01:00
draft = false
tags = ["security", "malware", "python", "tools", "cli", "dev"]
categories = ["Tools", "CLI"]
description = "How and why I created Virus.xcheck, a simple Python tool for checking file hashes against the Virus Exchange database."
+++

# Virus.xcheck: A Tool for Finding Malware Samples

I've always found it interesting how the security community shares and analyses malware samples. There's a great resource called [Virus Exchange](https://virus.exchange/) that serves as a repository for malware researchers and security professionals. However, quickly checking if multiple file hash exists in their database wasn't as straightforward as I wanted it to be.

## What is Virus.xcheck?

Virus.xcheck is a Python tool I created that quickly checks if a file hash exists in the Virus Exchange database. It's designed to be simple yet useful, making it easy to verify whether a suspicious file has been previously identified and cataloged.

## How It Works

At its core, Virus.xcheck is pretty straightforward:

1. It takes SHA-256 hashes either from a CSV file or directly from the command line
2. It checks each hash against the Virus Exchange API 
3. If the API doesn't respond, it has a fallback mechanism that directly checks the S3 bucket
4. It returns detailed metadata about any matches found
5. It provides integration with VirusTotal for additional context

## Recent Updates

I recently pushed some updates to Virus.xcheck which I thought were useful. Instead of just interacting with the CLI, I implemented interactive HTML report generation. Now when you run the tool with the `--html` flag, it generates a nice report with charts showing detection rates, file metadata, malware tag classifications, and detailed scan results.

I also improved the VirusTotal integration, which gives you additional context about the files beyond what Virus Exchange provides. This is particularly useful when Virus Exchange doesn't have a matching sample but VirusTotal does.

## Community Response

I was honestly surprised by the positive response the tool received when I first created it. I posted about it on X (formerly Twitter) in December, and it caught the attention of Virus.Exchange themselves, who reposted it.

{{< rawhtml >}}
<blockquote class="twitter-tweet"><a href="https://twitter.com/0xlews/status/1732163701094932950"></a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
{{< /rawhtml >}}

## How to Use It

If you want to try it out, it's pretty simple to get started:

1. Clone the repository
2. Install the required packages with `pip install -r requirements.txt`
3. Get an API key from [Virus.Exchange](https://virus.exchange/)
4. Create a `.env` file with your API key or pass it via command line

Then you can use it to check a single hash:

```bash
python virusxcheck.py -s "hash_value"
```

Or process multiple hashes from a CSV file:

```bash
python virusxcheck.py -f path/to/hashes.csv
```

You can also save the results to a file:

```bash
python virusxcheck.py -f path/to/hashes.csv -o results.csv
```

And generate that HTML report I mentioned:

```bash
python virusxcheck.py -f path/to/hashes.csv --html report.html
```

## What's Next?

I think it's useful enough as it is. No need to over-engineer something which doesn't need to be.

If you have any other suggestions, feel free to reach out!

## Final Thoughts

Building Virus.xcheck was a fun weekend project that turned into something unexpectedly useful. It's a reminder of why I like making things - being able to create tools that solve real problems (even if they're just my own problems initially).

If you're interested in checking it out or contributing, the code is available in my GitHub repository. And if you're into security research or malware analysis, I hope you find it as useful as I have!