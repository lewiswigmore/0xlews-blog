+++
title = 'Kusto Detective Agency - Season 1 Walkthrough'
date = 2025-01-16T22:00:00+01:00
draft = false
tags = ["kusto", "kql", "challenge", "tutorial"]
categories = ["Kusto", "Azure", "Tutorials"]
description = "A walkthrough of the Kusto Detective Agency Season 1 challenges with hidden solutions you can reveal when ready."
+++

# Kusto Detective Agency
Walkthrough of answers for Kusto Detective Agency Season 1

Welcome to the Kusto Detective Agency! This blog post provides a walkthrough for the Season 1 challenges, with the Kusto query answers hidden in collapsible sections so you can try to solve the challenges yourself first.

> **Hints**: Remember if you get stuck to refer to the hints in this answer sheet and in Kusto Detective Agency before checking the answers!

## Getting Started

Your first task is to create a free Kusto cluster which will be your primary investigation tool. Then you'll have to answer a simple question to get started. To create a free Kusto cluster, you need either a Microsoft account (MSA) or an Azure Active Directory (AAD) identity.

Create your cluster here: [https://aka.ms/kustofree](https://aka.ms/kustofree)

To provide your cluster URI you can use the following command:
```kusto
print current_cluster_endpoint()
```

The Kusto summarize operator is used to compute aggregations over specified data columns, allowing for data analysis in your queries.

### Welcome to the Kusto Detective Agency! (Answer)

{{< collapse summary="Click to reveal the answer" >}}
```kusto
Onboarding
| summarize sum(Score)
```
{{< /collapse >}}

## The Rarest Book is Missing!

This was supposed to be a great day for Digitown's National Library Museum and all of Digitown.

The museum has just finished scanning more than 325,000 rare books, so that history lovers around the world can experience the ancient culture and knowledge of the Digitown Explorers.

The great book exhibition was about to re-open, when the museum director noticed that he can't locate the rarest book in the world: "De Revolutionibus Magnis Data", published 1613, by Gustav Kustov.

The mayor of the Digitown herself, Mrs. Gaia Budskott - has called on our agency to help find the missing artifact.

Luckily, everything is digital in the Digitown library:
- Each book has its parameters recorded: number of pages, weight.
- Each book has RFID sticker attached (RFID: radio-transmitter with ID).
- Each shelve in the Museum sends data: what RFIDs appear on the shelve and also measures actual total weight of books on the shelve.

Unfortunately, the RFID of the "De Revolutionibus Magnis Data" was found on the museum floor - detached and lonely.

Perhaps, you will be able to locate the book on one of the museum shelves and save the day?

The weight measurement on the shelves isn't absolutely precise. The shelves' data includes book references (rf_ids) and the total weight of the books as measured by the shelf.

### The Rarest Book is Missing! (Answer)

{{< collapse summary="Click to reveal the answer" >}}
```kusto
// Each book has its parameters recorded: number of pages, weight.
// Each book has RFID sticker attached (RFID: radio-transmitter with ID).
// Each shelve in the Museum sends data: what RFIDs appear on the shelve and also measures actual total weight of books on the shelve.
// Find weight of the missing book
Books
| where book_title == "De Revolutionibus Magnis Data"
| project weight_gram

// Find the expected weight per shelf
let ExpectedWeightPerShelf = 
Shelves 
// Modify shelf array into each rf_id
| mv-expand rf_id = rf_ids to typeof(string) 
| join kind=inner (
    Books
    | project rf_id, weight_gram
    ) on rf_id
// Calculate expected total weight
| summarize ExpectedTotalWeight = sum(weight_gram) by shelf;

ExpectedWeightPerShelf
| join kind=inner (
    Shelves
    | project shelf, total_weight
    ) on shelf
// Calculate actual weight difference
| extend WeightDiff = total_weight - ExpectedTotalWeight
| where WeightDiff > 1700
```
{{< /collapse >}}

## Election Fraud?

The mayor of Digitown, Mrs. Gaia Budskott, has found herself in quite a pickle. The election for the city's mascot was run online for the first time, and it was a huge success! Or was it??

Over 5 million people voted. Four candidates made it to the final round:
- Kastor the Elephant – The darling of Digitown Zoo
- Gaul the Octopus – A Digitown celebrity, who was a whiz at predicting who'd win the local soccer games
- William (Willie) the Tortoise – Digitown's oldest living creature (estimated age - 176.4 years)
- Poppy the Goldfish – ex-Mayor Jason Guvid's childhood pet

The polls predicted a close battle between Kastor and Gaul, but the actual results showed that the ex-mayor's fish got a whopping 51.7% of all votes! That sure does sound fishy...

The mayor is afraid of a vote-tampering scandal that could affect all elections in Digitown! You've helped her out last time, and she's counting on you to get to the bottom of this mystery.

If voting fraud happened – prove it and correct the election numbers: what percentage of the votes did each candidate get?

You have access to the elections data: IP, anonymized id, vote, date-time - and the function used for counting the votes.

Analyse votes for anomalies, particularly focusing on Poppy's votes.

### Election Fraud? (Answer)

{{< collapse summary="Click to reveal the answer" >}}
```kusto
// Duplicate votes
let DoubleVotes =
Votes
| summarize VotesPerId=count() by voter_hash_id
| where VotesPerId > 1;

Votes
| where voter_hash_id in (DoubleVotes)

// Anomaly votes
Votes
| summarize Poppy_votes = countif(vote=="Poppy")
    by via_ip
| order by via_ip
| render timechart

// Suspicious IPs
Votes
| summarize VotesPerSec=count() by via_ip, bin(Timestamp, 1s)
| where VotesPerSec > 1
| distinct via_ip;

// Initial Solution - Failed
// Attempted to filter out votes from suspicious IPs and duplicate voters
let DoubleVotes = 
    Votes
    | summarize VotesPerId=count() by voter_hash_id
    | where VotesPerId > 1
    | distinct voter_hash_id;
let SuspiciousIPs = 
    Votes
    | summarize VotesPerSec=count() by via_ip, bin(Timestamp, 1s)
    | where VotesPerSec > 1
    | distinct via_ip;
Votes
| where via_ip !in (SuspiciousIPs) and voter_hash_id !in (DoubleVotes)
| summarize Count=count() by vote
| as hint.materialized=true T
| extend Total = toscalar(T | summarize sum(Count))
| project vote, Percentage = round(Count*100.0 / Total, 1), Count
| order by Count

// Solution - Focus on anomalous voting
// Ignoring duplicate voters and filtering out fraud counting patterns
Votes
| summarize Count=count() by vote, via_ip, bin(Timestamp, 1s)
| extend Count=iff(Count > 1, 0, Count)
| summarize Count=sum(Count) by vote
| as hint.materialized=true T
| extend Total = toscalar(T | summarize sum(Count))
| project vote, Percentage = round(Count*100.0 / Total, 1), Count
| order by Count
```
{{< /collapse >}}