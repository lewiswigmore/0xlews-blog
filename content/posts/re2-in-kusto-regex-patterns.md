+++
title = 'RE2 in Kusto: The Regular Expression Cheat Sheet'
date = 2025-03-02T18:05:00+01:00
draft = false
tags = ["kusto", "kql", "regex", "data analysis", "azure"]
categories = ["Docs", "Kusto", "Azure"]
description = "A practical guide to RE2 regular expressions in Kusto Query Language with real-world examples from my daily work."
+++

# RE2 in Kusto

If you work with Kusto (Azure Data Explorer), you're inevitably going to find yourself needing regular expressions. As someone who writes Kusto queries daily in security operations, I've developed a love-hate relationship with RE2 regex in KQL. It's so powerful, but can be difficult to get your head around. This is my personal cheat sheet that I refer to, and I hope it saves you some time too.

> A quick note: Kusto specifically uses RE2 regex, which has some differences from other regex flavors.

## The Basics: Characters and Classes

When I'm trying to match specific patterns in log data, here are the basics:

| Symbol | What it does | Example in Kusto |
|--------|--------------|------------------|
| `.` | Matches any character | `where Message matches regex "error.*"` |
| `[xyz]` | Character class - matches x, y, or z | `where Path matches regex "file[0-9]\.txt"` |
| `[^xyz]` | Negated character class | `where Username !matches regex "[^a-zA-Z0-9]"` |
| `\d` | Digit (0-9) | `where Id matches regex "ID\d+"` |
| `\D` | Non-digit | `where Field matches regex "\D+"` |
| `\s` | Whitespace | `where Command matches regex "ssh\s+-p"` |
| `\S` | Non-whitespace | `where Value matches regex "\S+"` |

## Composites and Repetitions

These help me define complex patterns and control how many times something appears:

| Pattern | Meaning | Example |
|---------|---------|--------------|
| `xy` | x followed by y | `"GET /api"` |
| `x*` | Zero or more x | `where Path matches regex "/api/v[0-9]\*/users"` |
| `x+` | One or more x | `where Message matches regex "fail\+"` |
| `x?` | Zero or one x | `where Email matches regex "support(-team)?@company\.com"` |
| `x{n,m}` | n to m occurrences | `where IP matches regex "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"` |

## Anchors and Boundaries

Whenever you need to ensure you're matching complete fields rather than partial text, you use anchors and boundaries:

| Symbol | Position | Example |
|--------|----------|---------|
| `^` | Start of string/line | `where Command matches regex "^sudo "` |
| `$` | End of string/line | `where Domain matches regex "\.com$"` |
| `\b` | Word boundary | `where Message matches regex "\berror\b"` |
| `\B` | Non-word boundary | `where Text matches regex "\Bcraft"` |

## Regex Patterns I Use Frequently

These are patterns that have saved me so much time, I keep them noted so forget how to write them:

### IP Address Matching

```kusto
let suspicious_traffic = 
NetworkLogs
| where SourceIP matches regex @"\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b"
| where SourceIP !matches regex @"\b(?:10|172\.(?:1[6-9]|2[0-9]|3[01])|192\.168)\.(?:\d{1,3})\.(?:\d{1,3})\b";
```

This pattern matches valid IPv4 addresses but the second part excludes private IP ranges.

### Parsing Custom Log Formats

There are often application logs that don't follow standard formats. Here's how I extract fields:

```kusto
SecurityEvents
| extend ParsedFields = parse_json(RawData)
| extend Timestamp = extract(@"timestamp[\":](\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})", 1, tostring(ParsedFields.raw))
| extend Username = extract(@"user[\":]([^\"]+)", 1, tostring(ParsedFields.raw))
| where isnotempty(Username)
```

### Finding Sensitive Data Patterns (data loss prevention)

If you've heard of DLP, there are kind of important:

```kusto
let regex_credit_card = @"\b(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|6(?:011|5[0-9]{2})[0-9]{12}|(?:2131|1800|35\d{3})\d{11})\b";
let regex_ssn = @"\b\d{3}-\d{2}-\d{4}\b";

SensitiveDataLogs
| where Message matches regex regex_credit_card or Message matches regex regex_ssn
| extend MatchType = case(
    Message matches regex regex_credit_card, "Credit Card",
    Message matches regex regex_ssn, "SSN",
    "Unknown"
)
```

## More Patterns I Always Forget (and have to look up)

Despite using these, some patterns are too hard to remember:

### Email

```
\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b
```

### GUID/UUID

```
[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}
```

### Base64

```
(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?
```

## Performance Optimisation Tips

After optimising countless slow queries, these are my golden rules:

1. **Avoid leading wildcards when possible** - `matches regex "^prefix"` is much faster than `matches regex ".*suffix"`

2. **Use string functions first, regex second** - If you can use `startswith()`, `contains()`, or `endswith()` instead of regex, do it. They're much faster.

3. **Pre-filter your data** - Always reduce your dataset as much as possible before applying regex:

```kusto
// Bad approach
TableWithMillionsOfRows
| where Message matches regex "some_complex_pattern"

// Good approach
TableWithMillionsOfRows
| where Timestamp between (ago(5m) .. now()) // Time filter
| where Message has "error" // Indexed operation first
| where Message matches regex "some_complex_pattern"
```

4. **Break complex regex into multiple simpler ones** - Sometimes multiple simple patterns are faster than one complex one.

5. **Always test on a small dataset first** - I can't count how many times I've crashed my browser with an inefficient regex on a large dataset.

## Extracting with Regex

Beyond just matching, extraction is also really useful in Kusto:

```kusto
SecurityLogs
| extend ExtractedFields = extract_all(@"(\w+)=([^;]+);", dynamic(["Key", "Value"]), Message)
| mv-expand ExtractedFields
| extend Key = tostring(ExtractedFields[0]), Value = tostring(ExtractedFields[1])
| summarize Values = make_set(Value) by Key
```

This pattern is really useful for breaking apart key-value pairs in logs.

## Conclusion

Regular expressions in Kusto have saved me countless amounts of time of manual data parsing, but they do come with a learning curve. Copy, bookmark, whatever this cheat sheet, and remember that the best regex is the one that's just complex enough to do the job without being so complex that you can't understand it a week later.

---

*This post is part of my Kusto series, where I share the stuff I use daily for investigations and data analysis.*