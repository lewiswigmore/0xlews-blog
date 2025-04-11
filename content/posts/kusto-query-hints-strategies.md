+++
title = 'Kusto Query Hints and Strategies'
date = 2025-01-27T21:40:00+01:00
draft = false
tags = ["kusto", "azure", "data analysis"]
categories = ["Docs", "Kusto", "Azure"]
description = "A practical guide to the Kusto query hints and strategies I use to optimise performance when working with massive datasets."
+++

# Kusto Query Hints and Strategies

When you're working with a large volume of log data, query performance becomes more important.

If you've ever stared at a loading screen while your Kusto query slowly runs in the background, this post is for you. Alternatively, if you grab a cup of tea while your query is running, you're probably okay to not bother reading this. However, these are some performance hints I actually use (sometimes), not just theoretical optimisations.

## Why Query Hints Matter

Kusto's query engine makes good decisions most of the time, but hints let you share your knowledge with the engine and how it join data together.

### `hint.strategy = shuffle`

This is the hint I reach for when I'm joining large tables or doing massive summarize operations:

```kusto
SecurityEvents
| where TimeGenerated > ago(7d)
| join hint.strategy = shuffle (
    SigninLogs 
    | where TimeGenerated > ago(7d)
) on $left.AccountName == $right.UserPrincipalName
```

What it does: Distributes your data processing across cluster nodes instead of doing everything on a single node. This is good when you're joining two large tables and I use this any time I see a query timing out with large datasets

### `hint.shufflekey = <key>`

This is the more precise version of the shuffle strategy:

```kusto
SecurityEvents
| summarize hint.shufflekey = Computer count() by Computer, bin(TimeGenerated, 1h)
```

You can use this when you know exactly which column has high cardinality (a relationship with another table).

### `hint.materialized = true`

This is useful for a dashboard query that run repeatedly:

```kusto
let AllEvents = materialize(SecurityEvents 
    | where TimeGenerated > ago(1d)
    | where EventID in (4624, 4625, 4634));
AllEvents | where EventID == 4624 | count;
AllEvents | where EventID == 4625 | count;
```

This caches intermediate results in memory so they can be reused across multiple steps. You can use this when the same filtered dataset is used multiple times.

### `hint.concurrency = <number>`

I find this one's hit or miss but helpful when used correctly:

```kusto
SecurityEvents
| where TimeGenerated > ago(1h)
| summarize hint.concurrency = 8 count() by EventID, Computer
```

This can be used to speed up queries that can be parallelised. Apparently, setting this too high can actually hurt performance... I don't use this often.

### `hint.num_partitions = <number>`

Similar to concurrency, but focuses on data partitioning:

```kusto
SecurityEvents
| where TimeGenerated > ago(7d)
| summarize hint.num_partitions = 128 count() by EventID
```

This is used for extremely large datasets where the default partitioning is insufficient/

## Resource Management Hints

These hints help me be a good person on shared datasets, avoid query timeouts, and overloading clusters:

### `hint.query_timeout = <time>`

```kusto
SecurityEvents
| where TimeGenerated > ago(180d)
| summarize hint.query_timeout = time(10m) count() by EventID
```

This sets a maximum time the query will run before giving up and is good to avoid tying up resources for too long.

### `hint.max_memory_consumption_per_query = <size>`

```kusto
SecurityEvents
| where TimeGenerated > ago(90d)
| summarize hint.max_memory_consumption_per_query = 4gb count() by EventID, Computer
```

This is also useful for queries on shared clusters where I need to control resource usage and when I'm getting memory-related failures.

## Cluster Management Hints (I don't use this all that often)

These are more specialised but extremely useful in certain scenarios:

### `hint.remote = true`

```kusto
SecurityEvents <| 
hint.remote=true
cluster('security-uksouth').database('SecLogs').SecurityEvents
```

This is supposed to be useful when working with data across multiple clusters and for cross-region analytics.

### `hint.distribution = <strategy>`

```kusto
SecurityEvents
| summarize hint.distribution = per_node count() by Computer
```

Options include:
- `per_node`: Each node processes its local data independently
- `per_shard`: Processing happens per data shard
- `single`: Forces single-node execution

When I use it:
- I don't yet... could be helpful for you though.

## An Example

Here's an example from actual work (sanitised, of course) that uses multiple hints to optimise a complex query:

```kusto
let timeframe = 14d;
let suspicious_signins = 
    SigninLogs
    | where TimeGenerated > ago(timeframe)
    | where ResultType == "50126" // Invalid username or password
    | summarize hint.strategy = shuffle 
        hint.shufflekey = IPAddress
        count() by IPAddress, bin(TimeGenerated, 1h)
    | where count_ > 20; // Threshold for brute force attempts

let affected_accounts = 
    SigninLogs
    | where TimeGenerated > ago(timeframe)
    | where IPAddress in (suspicious_signins) and ResultType == "0" // Successful login
    | summarize hint.materialized = true by UserPrincipalName;

affected_accounts
| join hint.strategy = broadcast (
    SecurityEvents
    | where TimeGenerated > ago(timeframe)
    | where EventID == 4728 // Member added to security-enabled global group
) on $left.UserPrincipalName == $right.TargetUserName
```

This query will:
1. Identify potential brute force attempts using the shuffle strategy
2. Materializes the list of affected accounts for reuse
3. Uses a broadcast join (small table to large table) to find security events associated with those accounts. This isn't that important on small datasets though.

## Final Thoughts

Query hints should be your last resort, not your first approach. Always try to optimise your query structure and filters first. But when you're dealing with massive datasets and complex operations, these hints can be the difference between a query that runs in seconds and one that times out.

Remember that every hint is essentially telling the query engine "I know better than you about my data," so use them thoughtfully and test the performance impact each time.

---

*This post is part of my Kusto series, where I share the stuff I use daily for investigations and data analysis.*