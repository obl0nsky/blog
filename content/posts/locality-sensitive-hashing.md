---
title: "Locality-sensitive hashing (Septimus II)"
date: 2018-02-28
tags: septimus
draft: false
markup: "mmark"
---

The paper we shall be looking at in this post will be: [Similarity Search in High Dimensions via Hashing](http://www.vldb.org/conf/1999/P49.pdf). Albeit, we will describe the procedure with more modern and standardised  terminology.

The core idea of the paper is to introduce the notion of _Locality-Sensitve Hashing_.

## Locality-Sensitive Hashing

### Motivation
Suppose we have an album of images and want to know which one most resembles a new image. Or imagine we have a list of pub locations in a city and want to know which one of these is closest to a given a person's location. Both these situations are part of a more general class of problems called a _nearest-neighbour_ search (or _k-nearest-neighbour_ search if we want to find multiple close values).

Formally defined, suppose we have metric space \\((M, d)\\) and a set of objects \\(C \subseteq M\\) containing elements \\(c_i, \dots, c_n\\). Suppose also we have a query object \\(q \in M\\). How can we efficiently find the 'closest' object \\(C\\) to \\(q\\)? That is, how can we find:

$$\underset{i}{\arg\min} d(q, c_i).$$

### Idea
If \\(n\\) is fairly small and \\(d\\) is not computationally expensive, then we can just loop through the elements of \\(C\\) one by one and see which is the closest. However, when a full brute-force for every query is not computationally feasible, we need an alternative approach. This is the problem that Locality-Sensitive Hashing attempts to solve, albeit at the expense of perfect accuracy (that is, we will get a _close_ object, but not necessarily the _closest_).

The core idea of Locality-Sensitive Hashing is that we apply a hash function to each of the objects which preserves a notion of 'similarity' when comparing the hashes. This is done offline as a one time event and then the results are stored. Then, when we are given a query object \\(q \in M\\), we also hash it and we can efficiently find (the process of which will be described later) a "small" number of objects with a close hash. We then either find the object from this subset that has the smallest distance using the distance function \\(d\\) or by using a distance function on the result of the hashes.

Specifically, we construct a hash function \\(h : C \to \lbrace 0, 1 \rbrace^t\\) for some \\(t\\), the range of which is the Hamming space.  

### What does it mean to preserve similarity
In the above description, we said that the hashing function should preserve similarity. What does this mean? A _similarity function_ is a function \\(sim : C \times C \to [0,1]\\) for which a result of 0 indicates no similarity between the two arguments, and a result of 1 indicates high similarity (or equality). For a hashing function to preserve similarity we require that

$$\mathbb{P}[h_r(x) = h_r(y)] = sim(x, y).$$


### Vector space
For the original Locality-Sensitive hashing algorithm we also suppose that \\(M\\) is also an inner product space[^1]. That is, it is a vector space with an inner product function. We can construct a hash function as follows. Choose a random hyperplane (as defined by a vector \\(r\\), where each coordinate is selected from a Gaussian with mean 0) that passes through the origin of this vector space. Then, for any given object \\(c \in M\\), we can define

$$h_r(c) = \begin{cases}
   1, &\text{if } \langle r, c \rangle \geq 0   \\
   0, &\text{otherwise}
\end{cases}$$

This essentially says, that \\(h_r(c)\\) is either 1 or 0, depending on which side of the hyperplane \\(c\\) lies (when visualising the vector in a high dimensional space).

Inner products induce the notion of _angles_ between two vectors:

$$\angle(x, y) := \arccos \frac{|\langle x, y \rangle|}{\|x\|\|y\|}.$$

For \\(x, y \in M\\), we have:

$$\mathbb{P}[h_r(x) = h_r(y)] = 1 - \frac{\angle(x, y)}{\pi}.$$

Although we won't prove this claim, we can get an intuition of it by considering the case of \\(\mathbb{R}^2\\). Take two random points on a plane. Draw a line to the origin from each. Call the angle between these two lines \\(\theta\\). Now pick a random line through the origin. It has a \\(\frac{\theta}{\pi}\\) chance of bisecting the two points. If it does bisect, the inner product of one point with the random vector will be positive, and the other will be negative and so the results of  applying the hash function will be different. In all other cases, the hash function will be the same.

If the angle between \\(x\\) and \\(y\\) is small, then the probability of a hash collision is high. If it's large, then the probability is low. Therefore, as it also must lie between \\(0\\) and \\(1\\), we have the right hand side is a similarity function and thus the hash function is similarity preserving.

### 'Super' hash

The problem, however, is that we are reducing every object down to a single bit. We only have two types of object, those that hash to a \\(0\\) and those that hash to a \\(1\\). Can we construct a hash which uses similar ideas yet retains more information? Yes, we extend the idea by picking \\(m\\) random hyperplanes, defined by \\(r_1, \dots, r_m\\), and create a "super" hash by concatenating the hash function induced by each \\(r_i\\). That is \\(h(c) := h_1(c), h_2(c), \dots, h_m(c)\\).

We note that the more similar binary strings are, the more 'similar' (in terms of cosine distance) they are.

A> Question for author: Can we do better than choosing each \\(r_i\\) randomly if we know the data in advance.

### Search
We can now describe the efficient search that can take place when we receive a query vector \\(q \in M\\). We need to do more pre-processing. We select \\(N\\) random permutations (\\(\sigma_1, \dots, \sigma_N\\)) of the bits in our \\(t\\)-dimensional Hamming space. Store a list of lexicographically sorted hashes for each permutation. That is for each, \\(\sigma_i\\), store a sorted version of \\(\sigma_i(h(c_1)), \dots, \sigma_i(h(c_n))\\). Call this \\(L_i\\).

Now, when our query vector \\(q\\) is provided, we calculate its hash, and each permutation of that hash. We then look to see the position in each \\(L_i\\) that \\(\sigma_i(h(q))\\) would take were it sorted within. Take the permuted hash one place above and one place below this position for each \\(L_i\\). We now have \\(2N\\) candidates for being the nearest-neighbour. Either pick the one with the longest prefix match of \\(\sigma_i(h(q))\\) to its neighbour in \\(L_i\\) or use the distance function \\(d\\) from the original metric space to find the minimal distance of the candidates.

Because searching a sorted list is \\(\mathcal{O}(\ln n)\\), we have the whole search process taking around \\(\mathcal{O}(N\ln n)\\). This is an improvement on the \\(\mathcal{O}(n)\\) of the original brute force when we have a reasonably small \\(N\\). We can vary \\(N\\) to get more accurate results at the expense of additional computation.


## Conclusion

We've successfully made a hard search problem more efficient. In practice this enables powerful things like Google's reverse image search or Souncloud's song recommendation system that would never have been feasible with a brute force approach.

### Real life analogy
We can think of the process as akin to a guessing game. Suppose I have just finished reading _Wolf Hall_ - Hilary Mantel's fictionalised biography of Thomas Cromwell - and I'd like to find a similar book to read. I go down to the library and speak to the librarian who asks me questions about the book (without knowing exactly what it is). She has organised the register of books in her library according a pre-determined list of properties. She has a list of non-fiction books and a list of fiction books. Then for each of these lists, it is further broken down into whether they concern events before or after 1900. And so on into further sub-lists for more criteria. So she asks:
1. Is it a fiction book (Yes, but only just)
2. Are the events set pre-1900 (Yes)
3. Is the protagonist female (No)
4. etc...

After question one, she will discard her 'non-fiction' pile. She's left with a pile of fiction book pre-1900 and a pile of fiction books post 1900. She then discards the post-1900 file and so on. After these 3 questions, we are left with a list of books which share the same properties as Wolf Hall - and the librarian never had to scan the list of books manually - she just discarded whole groups of books as we went. We continue the process until we have only two books left (backtracking to a wrong answer pile if we run out of books).

However, there is a problem with this. What if the most similar book is actually Tracey Borman's historical biography of Thomas Cromwell? As it is a non-fiction book, this was discarded at the very first stage by the librarian! We need to visit another librarian who has organised the books according to the same questions, but in a different order.

So we tour 10 librarians who each have different ordering systems and get 2 book recommendations from each. From there we just manually inspect the 20 books to see which one is closet to _Wolf Hall_. This is a far more efficient way than manually looking at every book in the library to see how similar it is to Wolf Hall!



## Sources

- [Similarity Search in High Dimensions via Hashing - Gionis et al (1999)](http://www.vldb.org/conf/1999/P49.pdf)
- [Kernelized Locality-Sensitive Hashing for Scalable Image Search - B Kulis et al (2010)](http://www.cs.utexas.edu/~grauman/papers/iccv2009_klsh.pdf)
- [Similarity Estimation Techniques from Rounding
Algorithms - Charikar (2002)](https://www.cs.princeton.edu/courses/archive/spr04/cos598B/bib/CharikarEstim.pdf)


[^1]: There are extensions of the theory such as that by [_Kulis et al_](http://www.cs.utexas.edu/~grauman/papers/iccv2009_klsh.pdf) which generalise the process to a much broader class of spaces
