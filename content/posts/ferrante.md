---
title: "Elena Ferrante Unmasked (Septimus III)"
date: 2018-03-05
tags: septimus
draft: false
markup: "mmark"
---

The paper we shall be looking at in this post will be: [Elena Ferrante Unmasked](https://www.researchgate.net/profile/Jacques_Savoy/publication/320131096_Elena_Ferrante_Unmasked/links/59cfbfbc0f7e9b4fd7f47618/Elena-Ferrante-Unmasked.pdf?origin=publication_detail).

## Authorship attribution

Since the early 1990s and the proliferation of computer aided textual analysis, various attempts have been made to attribute authorship to various texts whose previous authorship was unknown or disputed. Much of this work has focussed on the works of Shakespeare. For example, in 2009, Sir Graham Vickers [provided evidence](https://www.thetimes.co.uk/article/computer-program-proves-shakespeare-didnt-work-alone-researchers-claim-7m0pv78bk2z) using plagiarism software that the anonymously published play _Edward III_ was likely to have been partially written by Shakespeare:

> [Vickers] discovered that playwrights often use the same patterns of speech, meaning that they have a linguistic fingerprint. The program identifies phrases of three words or more in an author’s known work and searches for them in unattributed plays. In tests where authors are known to be different, there are up to 20 matches because some phrases are in common usage. When Edward III was tested against Shakespeare’s works published before 1596 there were 200 matches.

A> Question for author: was this normalised somehow?

In 2018, Dennis McCarthy and June Schlueter [unearthed](https://www.nytimes.com/2018/02/07/books/plagiarism-software-unveils-a-new-source-for-11-of-shakespeares-plays.html) a potential new source of inspiration for Shakespeare, George North's manuscript titled _A Brief Discourse of Rebellion and Rebels_, using a similar technique:

> Mr. McCarthy used decidedly modern techniques to marshal his evidence, employing WCopyfind, an open-source plagiarism software, which picked out common words and phrases in the manuscript and the plays.

> In the dedication to his manuscript, for example, North urges those who might see themselves as ugly to strive to be inwardly beautiful, to defy nature. He uses a succession of words to make the argument, including “proportion,” “glass,” “feature,” “fair,” “deformed,” “world,” “shadow” and “nature.” In the opening soliloquy of Richard III (“Now is the winter of our discontent...”) the hunchbacked tyrant uses the same words in virtually the same order to come to the opposite conclusion: that since he is outwardly ugly, he will act the villain he appears to be.

The idea is to reduce a text down to various statistics and see how those  compare between texts.

## Elena Ferrante
Elena Ferrante is an anonymous author. 'She' has published several novels in Italian including the critically acclaimed and commercially successful series dubbed _The Neapolitan Novels_. Due to the eminence of these books, there has been wild speculation on the true identity of the author with numerous wannabe detectives thinking they have deduced it.

One [attempt](https://www.nytimes.com/2016/03/14/books/who-is-elena-ferrante-an-educated-guess-causes-a-stir.html?_r=0) to uncover the identity, done by Marco Santagata, used traditional intuitive pattern matching:

> “I did philological work, as if I were studying the attribution of an ancient text, even though it’s a modern text,” added Mr. Santagata, a philologist by training and an expert on Petrarch and Dante who teaches at the University of Pisa.

> [...]

> “I created a profile [...]” Mr. Santagata said in a telephone interview. [...] He said he had determined that some street names in the books were changed in Pisa after 1968, suggesting that the author must have left Pisa before then. Looking in Scuola Normale yearbooks, he found she seemed to be the only Neapolitan woman at Pisa in the mid 1960s who had become an expert in the contemporary Italian history that is the backdrop to Ms. Ferrante’s Naples books.

A different attempt, this time by correlating a literary couple's financial situation with the success of the books appears more convincing. Claudio Gatti [suspects](http://www.nybooks.com/daily/2016/10/02/elena-ferrante-an-answer/) that the true identity of the author is Anita Raja, a Rome-based translator. He notes:

> Public real estate records show that in 2000, after Ferrante’s first book was turned into a successful movie in Italy, Raja acquired in her own name a seven-room apartment near Villa Torlonia, an expensive area of Rome; the following year she bought a country home in Tuscany.

> [...]

> Even more significant is the pattern of payments from Edizione [the Rome-based publisher of Ferrante's works] e/o to Raja in the years since Ferrante’s books reached the international market. Edizioni e/o’s annual revenues for 2014 were €3,087,314, a 65 percent increase from the previous year. In 2015, revenues went up another 150 percent, reaching €7,615,203. These extraordinary increases appear to be a direct result of Ferrante’s sales; the publisher had no other comparable bestsellers during these years. The growth in the publisher’s revenues are also closely paralleled in the growth of Raja’s own payments from Edizioni e/o over the same period, which I obtained from an anonymous source. In 2014, Raja’s compensation increased by almost 50 percent, and in 2015 it grew again by more than 150 percent, reaching an amount that was about seven times what she received in 2010, when the market for Ferrante’s books was still confined to Italy.

A third attempt was to use a statistical analysis of the texts (also known as _stylometry_) and compare the results with a pool of candidate authors. This is the work done by Jacques Savoy in the paper which is the subject of this blog: _Elena Ferrante Unmasked_.

## Stylometric methods

The high level idea is to take a corpus of documents, quantify various style-related features from them and then pairwise compare the style of each document to see how similar they are.

For the analysis, Savoy collated a corpus of texts by a range of authors who might be candidates for the identity of Ferrante. He selected 150 books across 40 different authors including many of the main candidates suggested for authorship. He notes:
> This set contains ten authors originating from the region (Campania) that appear in the background of the My Brilliant Friend tetralogy.  In addition, when generating this corpus, thirteen female writers have been selected.  Therefore, one can conclude that a real effort has been deployed to include  many authors sharing some important extra-textual relationships with Ferrante (e.g., a woman coming from Naples or environs).   

### Tokenising

We prepare all the texts by _tokenising_ them first. This is a process whereby each word is 'normalised' This typically always involves initially stripping punctuation and numbers from words and converting to lower case.

Optionally, in addition, we can use a 'part-of-speech' tagger to annotate the word with how was used. For example, in the sentence, "Elena is anonymous", we'd have:

Word      | Part of speech
----------|---------------
elena     | proper noun
is        | verb
anonymous | adjective

Doing this computationally is a non-trivial task and there have been many attempts to implement algorithms to do it over the years. One of the main problems lies in the fact that we can't just have a mapping from a word to a part of speech as some words can be used in more than one way. For example, consider the sentence "Graham hounds the dilettante". In this instance, 'hounds' is used as a verb. Now consider the sentence "Andrew tended to the hounds". In this instance, 'hounds' is used as a plural noun.

Furthermore, consider the following sentence: "Simon was entertaining last night". We cannot deduce which part of speech 'entertaining' represents. Was Simon hosting guests, or was he providing delight?

These ambiguities might not be too problematic depending on what accuracy we would like to achieve. Work that has been done on a corpus of real world text has shown that if we assign to each word its most common part-of-speech, and assign 'proper noun' to any unknowns, we can attain 90% accuracy in the tagging.

One way to counter ambiguity is to consider the surrounding words. For example, an word following a 'the' is likely to be a noun or an adjective. So if the word 'hound' succeeds a 'the', we can be reasonably confident it won't be being used as a verb and so can attribute it to being a noun (as 'hound' cannot be used as an adjective). This idea has been formalised using hidden markov models and can achieve accuracy of 93-95%.

Another optional step of normalisation is to reduce verb conjugations to their 'dictionary entry' form. For example, _amico_, _amica_ and _amici_ should all be reduced to _amico_.

Picking which normalisation strategies to use is dependent on the context and maybe require subjective judgement. All that matters for the authorship identification techniques we define below is that for each corpus text, we normalise it to a list of tokens of the same type.

### Terminology
We shall define some terminology. Let \\(Q\\) be a query text (i.e. the text we would like to attribute authorship to) and let \\(A_1, \dots, A_k\\) be the corpus texts (i.e. the texts we would like out query text to match against). Let \\(C := A_1 + \dots + A_k\\) be the concatenation of all the corpus texts. Let \\(B_j\\) be the concatenation of all texts by author \\(j\\). Tokens will be referred to using the letter \\(t\\).

### Methods

#### Delta method

The first technique that Savoy employs is the delta method. This was first described in a paper titled [_‘Delta’: a Measure of Stylistic Difference and a Guide to Likely Authorship_](https://academic.oup.com/dsh/article/17/3/267/929277) by John Burrows. In it, he introduces the method and then shows that it can correctly identify the authors of texts by English Restoration poets such as John Milton. The technique is fairly elementary (although it was described as 'ground-breaking' in [one paper](https://academic.oup.com/dsh/article/32/suppl_2/ii4/3865676)!). We aim to give a query text \\(Q\\) a delta score (often just denoted with the character \\(\Delta\\)) against an author corpus \\(B_j\\). The lower the delta, the more similar the texts.

The way we calculate this is as follows. We take a list of \\(N\\) popular tokens. Often this is just the top \\(N\\) tokens in the entire corpus. For each token \\(t_i\\) in this list and for each author corpus \\(B_j\\) we first calculate the frequency with which that token appears in that corpus. That is,  we define

$$f_i(B_j) := \frac{|\{t : t \in B_j, t = t_i\}|}{|B_j|}$$

At this point, we could define

$$\Delta(Q, B_j) := \frac{1}{N} \sum_{1 \leq i \leq N} |f_i(Q) - f_i(B_j)|$$

which is the average difference in percentage for each of the top N token between the query text and a particular author's corpus. So if a particular author used the word 'the' 4.5% of the time, and the query text used it 5.1% of the time, that would contribute 0.6% in the summation.

There is a problem with this however. Word frequencies in most languages tend to follow Zipf's law. This states that the frequency of a word in a language is inversely proportional to it's ranking when the words are ordered by frequency. So we would expect the most frequent word to be twice as common as the second most frequent word, and three times as common as the third most frequent word. The ramification of this is that the differences in frequencies for the more common words will likely contribute a larger amount to the total delta score.

We therefore standardise the score such that for each token \\(t_i\\) such that it has a mean of 0 and standard deviation of 1 over all documents. We do this by calculating the frequency of a token in each corpus document \\(A_j\\). Then we take the mean and standard deviation of these frequencies - denote these as \\(\mu_i\\) and \\(\sigma_i\\), respectively. Finally, we define

$$ z_i(B_j) := \frac{f_i(B_j) - \mu_j}{\sigma_j}$$

A> Question for author: Why give equal weight to each word?

Finally, we define the refined version of the delta score:

$$\Delta(Q, B_j) := \frac{1}{N} \sum_{1 \leq i \leq N} |z_i(Q) - z_i(B_j)|$$

We look for the  author corpus with the smallest \\(\Delta\\).

The results of this technique is that every one of the seven Ferrante novels is closest to the Domenico Starnone corpus for each value of \\(N\\) (the number of most-frequently seen tokens to use) of 100, 200, 300, 400, 500, 1000, and 2000. We note here that Domenico Starnone is a Neapolitan novelist and is the husband of the afformentioned translator Anita Raja.

#### Labbé's distance

The second technique employed is using a distance defined by Dominique Labbé in a paper called [_'Experiments on Authorship Attribution by Intertextual
Distance in English'_](https://halshs.archives-ouvertes.fr/halshs-00139070/document). Again, we try to define some some or distance between two texts. This time, the calculation is independent of the entire corpus (unlike Burrows' \\(\Delta\\) which standardised based on the entire corpus). It can be expressed in a simple formula. First, let the _absolute frequency_ of a token be the number of times a token appears in a text. Define it as

$$g_i(A_j) := |\{t : t \in A_j, t = t_i\}|$$

Suppose we want to compute the distance between two texts \\(A_j\\) and \\(A_k\\). Without loss of generality assume that \\(A_j\\) has less tokens  than \\(A_k\\) (i.e. it is a shorter text). We define

$$g'_i(A_k) := g_i(A_k) \frac{|A_j|}{|A_k|}$$

to 'proportionalise' the frequencies in \\(A_j\\). Then finally we define the Labbé distance:

$$D(A_j, A_k) := \frac{1}{2|A_j|} \sum_{1 \leq i \leq N} |g_i(A_j) - g'_i(A_k)|$$

The summation varies over all \\(N\\) tokens seen in the concatenation of the two texts. We divide the sum by \\(2|A_j|\\) so the distance ranges from 0 to 1. If both texts have the exact same frequency of every token, each term in the summation will be 0 and so the distance will be zero. If every token in text \\(A_j\\) was different to every token in \\(A_j\\) (i.e. one text was in Arabic and one was in Portuguese), then the sum would add up to \\(|A_j| + |A_k||A_j|/|A_k| = 2|A_j|\\) so the distance would be 1.

A> Question for author: Is this basically equivalent to our first attempt at defining \\(\Delta\\) above?

Next, we calculate the Labbé distance for every pair of texts in our corpus (excluding Ferrante novels). From these scores we can construct a distribution of distances for texts with the same author and texts with different authors. Savoy chooses a beta distribution as this ranges between 0 and 1 (like the distance function) and can describe gaussian-like distributions (the distances cluster around a mean and then drop off on each side).

We calculate the distances of the Ferrante novels with every other text. If we order these by smallest distance first, we find that the first 10 or so texts are all Ferrante-Starnone pairs. Additionality, the distance between these is much closer to the mean of the same-author distance distribution than the mean of the different-author distribution. Savoy formalises this further. Using methods described in one of his own [previous papers](https://onlinelibrary.wiley.com/doi/pdf/10.1002/asi.23455) he claims "one can estimate the probability that Starnone is the author of Storia della bambina perduta [A Ferrante novel] with a probability of 0.99.". While the evidence is compelling, this seems to be a loose use of the word 'probability'. It does not account for our the uncertainty that the beta distribution is accurate (for example, consider constructing the beta distributions from a corpus consisting of two texts by Charles Dickens and 2 texts by Martin Amis - it wouldn't be representative of all texts).

A> Question for author: Might a more bayesian approach yield a better probability?

#### Nearest shruken centroids
Finally, we introduce the Nearest shrunken centroids technique.


## Conclusion

Each of these methods suggests the closet stylometric match in the corpus is the works of Dominique Starnone. However, the evidence to suggest that he is almost certainly the "hidden hand behind Elena Ferrante" remains not entirely convincing.

### Correlative techniques
Firstly, one might think that because we have used multiple different methods to attack the problem and they have all produced the same answer, then we should be much more confident than had we used just a single method. However, each of the three techniques applied in this paper is merely a variation on a single theme. They all analyse the frequency with which certain words are used in a text compared to other texts. We should expect to see a high correlation between the answers of each. Importantly, if there is an error in one analysis, it is likely to be present in all the analyses.

### Closed set search
Another criticism of the paper would be to note that it takes a self-confessed 'closed-set' approach. That is, it assumes the author must be one of the pre-selected candidates. Savoy notes that "[t]he underlying corpus contains all novelists that have been mentioned as possible secret hands behind Ferrante". However, as noted in the _New York Review of Books_ article above, Stanone's wife, Anita Raja is a likely candidate yet she has no works in the selected corpus. In fairness to Savoy, she has no original published works so her writing style could not be analysed.

### Attribution
Based on the traditional journalism, it seems highly likely that the author of the texts is either Anita Raja, Domenico Starnone or a collaboration between the two.

Based on the exposition in the present paper by Jacques Savoy, it appears that Starnone shares an unusually similar writing style to Ferrante.

Additional [qualitative analysis](http://www.the-next-stage.com/2017/03/laces-powerful-novel-by-domenico.html), provides biographyical evidence for the authorship of Starnone over Raja:
> The powerfully rendered portrait of growing up in deep poverty in 1950’s Naples feels like it was written from first hand experience. Raja did not have this direct experience but Starnone, like the fictional Ferrante, was the son of a seamstress and did grow up in Naples.

This correspondent concludes that is most likely that Starnone is Ferrante, followed by Ferrante as a joint project between the two (it would be hard not to collaborate on some level as a married couple) and finally the Raja is Ferrante. This correspondent assigns a negligible probability to any other author.
