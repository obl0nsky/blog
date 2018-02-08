---
title: "Kernelized locality-sensitive hashing"
date: 2018-01-31
tags: septimus
draft: true
markup: "mmark"
---

The paper we shall be looking at in this post will be: [Kernelized Locality-Sensitive Hashing for Scalable Image Search](https://arxiv.org/pdf/1703.00536.pdf).

Firstly, we shall introduce the idea of Locality-Sensitive Hashing.

## Locality-Sensitive Hashing

### Motivation
Suppose we have a gallery of images and want to know which one most resembles a new image. Or we have a corpus of poems and want to know

Suppose we have metric space \\((M, d)\\) and a set of objects \\(C \subseteq M\\) containing elements \\(c_i, \dots, c_n\\). Suppose also we have a query object \\(q \in M\\). How can we efficiently find the 'closest' object \\(C\\) to \\(q\\)? That is, how can we find:

$$\underset{i}{\arg\min} d(q, c_i).$$

### Idea
If \\(n\\) is fairly small and \\(d\\) is not computationally expensive, then we can just loop through \\(C\\) one by one and see which is the closest. However, when a brute-force for every query is not computationally feasible, we need an alternative approach. This is the problem that Locality-Sensitive Hashing attempts to solve, albeit slightly sacrificing accuracy (that is, we will get a _close_ object, but not necessarily the _closest_).

The core idea of Locality-Sensitive Hashing is that we apply a hash function to the objects which preserves a notion of 'similarity'. We then partition the objects into buckets based on the value of this function. Then, for a query object, we can also hash it and see which bucket it belongs to. Since the hash function retained a notion of 'similarity', the objects in that bucket should be close to our query object. We then perform a brute force on this subset to find the closest object in that bucket.

To illustrate the idea, imagine having 100 unmatched socks. Suppose we find 10 straggling socks and want to match them up to their partner in the original 100 socks. For each straggler, we could manually search through each sock to see if it matches. Or we could do some preprocessing to make each search quicker. This might be to group the socks into colours: black, gray and white. Now when we are trying to match up a sock, we only need to look in the pile of socks which matches the colour of that sock.

More formally, we create a function \\(h : M \to B\\) where \\(B = \lbrace b \in \mathbb{N} | b \leq N \rbrace \\) for some \\(N\\). Then we define

$$B_i = \lbrace c \in C | h(c) = i \rbrace.$$

Given an object \\(q\\), we calculate \\(h(q)\\). Call it \\(j\\). Then we find a close object by searching.

$$\underset{c \in B_j}{\arg\min} d(q, c).$$

### What does it mean to preserve similarity
In the above description, we said that the hashing function should preserve similarity. What does this mean, and what are some example functions?

A similarity function is a function \\(sim : C \times C \to [0,1]\\) for which a result of 0 indicates no similarity, and a result of 1 indicates high similarity (or equality). We say that a hash function


 If we have a notion of similarity between two (the phi function). Then mention cosine similarity. Reduce generality by talking about vectors.


To finish: https://arxiv.org/pdf/1110.1328.pdf section 2.



## Sources
http://mlwiki.org/index.php/Locality_Sensitive_Hashing
https://research.google.com/pubs/pub34634.html
