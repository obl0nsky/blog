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

In 2018, Dennis McCarthy and June Schlueter [unearthed](https://www.nytimes.com/2018/02/07/books/plagiarism-software-unveils-a-new-source-for-11-of-shakespeares-plays.html) a potential new source of inspiration for Shakespeare using a similar technique - George North's manuscript titled _A Brief Discourse of Rebellion and Rebels_:

> Mr. McCarthy used decidedly modern techniques to marshal his evidence, employing WCopyfind, an open-source plagiarism software, which picked out common words and phrases in the manuscript and the plays.

> In the dedication to his manuscript, for example, North urges those who might see themselves as ugly to strive to be inwardly beautiful, to defy nature. He uses a succession of words to make the argument, including “proportion,” “glass,” “feature,” “fair,” “deformed,” “world,” “shadow” and “nature.” In the opening soliloquy of Richard III (“Now is the winter of our discontent …”) the hunchbacked tyrant uses the same words in virtually the same order to come to the opposite conclusion: that since he is outwardly ugly, he will act the villain he appears to be.

The idea is to reduce a text down to various statistics and see how those  compare between texts.

## Elena Ferrante
Elena Ferrante is an anonymous author. 'She' has published several novels in Italian including the critically acclaimed and commercially successful series dubbed _The Neapolitan Novels_. Due to the eminence of these books, there has been wild speculation on the true identity of the author with numerous wannabe detectives thinking they have deduced it.

One attempt, by Marco Santagata, [was done](https://www.nytimes.com/2016/03/14/books/who-is-elena-ferrante-an-educated-guess-causes-a-stir.html?_r=0) using traditional investigative pattern matching:

> “I did philological work, as if I were studying the attribution of an ancient text, even though it’s a modern text,” added Mr. Santagata, a philologist by training and an expert on Petrarch and Dante who teaches at the University of Pisa.

> [...]

> “I created a profile — I didn’t say it was her,” Mr. Santagata said in a telephone interview, adding that he had never met or been in touch with Ms. Marmo. He said he had determined that some street names in the books were changed in Pisa after 1968, suggesting that the author must have left Pisa before then. Looking in Scuola Normale yearbooks, he found she seemed to be the only Neapolitan woman at Pisa in the mid 1960s who had become an expert in the contemporary Italian history that is the backdrop to Ms. Ferrante’s Naples books.

A different attempt, this time by correlating a literary couple's financial situation with the success of the books appears more convincing. Claudio Gatti [suspects](http://www.nybooks.com/daily/2016/10/02/elena-ferrante-an-answer/) that the true identity of the author is Anita Raja, a Rome-based translator. He notes:

> Public real estate records show that in 2000, after Ferrante’s first book was turned into a successful movie in Italy, Raja acquired in her own name a seven-room apartment near Villa Torlonia, an expensive area of Rome; the following year she bought a country home in Tuscany.

> [...]

> Even more significant is the pattern of payments from Edizione [the Rome-based publisher of Ferrante's works] e/o to Raja in the years since Ferrante’s books reached the international market. Edizioni e/o’s annual revenues for 2014 were €3,087,314, a 65 percent increase from the previous year. In 2015, revenues went up another 150 percent, reaching €7,615,203. These extraordinary increases appear to be a direct result of Ferrante’s sales; the publisher had no other comparable bestsellers during these years. The growth in the publisher’s revenues are also closely paralleled in the growth of Raja’s own payments from Edizioni e/o over the same period, which I obtained from an anonymous source. In 2014, Raja’s compensation increased by almost 50 percent, and in 2015 it grew again by more than 150 percent, reaching an amount that was about seven times what she received in 2010, when the market for Ferrante’s books was still confined to Italy.

A third attempt was to use a statistical analysis of the texts (also known as _stylometry_) and compare the results with a pool of candidate authors. This is the work done by Jacques Savoy in the paper which is the subject of this blog: _Elena Ferrante Unmasked_.

## Stylometric methods

The high level idea is to take a corpus of documents, quantify various style-related features from them and then pairwise compare the style of each document to see how similar they are.

For the analysis, Savoy collated a corpus of texts by a range of authors who might be candidates for the identity of Ferrante. He selected 150 books across 40 different authors including all the main candidates.

### Tokenising

We prepare all texts by _tokenising_ them first. This is a process whereby each word is 'normalised' by stripping punctuation and numbers and converting to lower case.

Optionally, in addition, we can use a 'part-of-speech' tagger to identify how a word was used. For example, in the sentence, "Elena is anonymous", we'd have:

Word      | Part of speech
----------|---------------
elena     | proper noun
is        | verb
anonymous | adjective

This is a non-trivial task and there have been many attempts to solve it over the years. We can't just have a mapping from a word to a part of speech as some words can be used in more than one way. For example, consider the sentence "Graham hounds the dilettante". In this instance, 'hounds' is used as a verb. Now consider the sentence "Andrew released the hounds". In this instance, 'hounds' is used as a plural noun.

Furthermore, consider the following sentence: "Simon was entertaining last night". We cannot deduce which part of speech 'entertaining' represents. Was Simon hosting guests, or was he providing delight?

[Insert bit about how POS is done here]

Another optional step of normalisation is to reduce verb conjugations to their 'dictionary entry' form. For example, _amico_, _amica_ and _amici_ will all be reduced to _amico_.

Picking which normalisation strategies to use is mainly an art. All that matters for the authorship identification techniques we define below is that for each corpus text \\(A_i\\), we normalise to a list of tokens of the same type.

### Terminology
We shall define some terminology. Let \\(Q\\) be a query text (i.e. the text we would like to attribute authorship to) and let \\(A_1, \dots, A_k\\) be the corpus texts (i.e. the texts we would like out query text to match against). Let \\(C := A_1 + \dots + A_k\\) be the concatenation of all the corpus texts. Let \\(B_i\\) be the concatenation of all texts by author \\(i\\). [will i actually use this?]. Tokens will be referred to using the letter \\(t\\).

### Delta method

The first technique that Savoy employs is the delta method. This was first described in a paper titled [_‘Delta’: a Measure of Stylistic Difference and a Guide to Likely Authorship_](https://academic.oup.com/dsh/article/17/3/267/929277) by John Burrows. In it, he introduces the method and then shows that it can correctly identify the authors of texts by English Restoration poets such as John Milton. The technique is fairly elementary. We aim to give a query text \\(Q\\) a delta score (often just denoted with the character \\(\Delta\\)) against a source text \\(A_i\\). The lower the delta, the more similar the texts.

The way we calculate this is as follows. We take a list of \\(N\\) popular tokens. Often this is just the top \\(N\\) token in the entire corpus. For each token \\(t_i\\) in this list and for each author corpus \\(B_j\\) we first calculate the frequency with which that token appears in that corpus. That is we define

$$f_i(B_j) := \frac{|\{t : t \in B_j, t = t_i\}|}{|B_j|}$$

At this point, we could define

$$\Delta(Q, B_j) := \frac{1}{N} \sum_{1 \leq i \leq N} |f_i(Q) - f_i(B_j)|$$

which is the average difference in percentage for each of the top N token between the query text and a particular author's corpus. So if a particular used the word 'the' 4.5% of the time, and the query text used it 5.1% of the time, that would contribute 0.6% in the summation.

There is a problem with this however. Word frequencies in languages tend to follow Zipf's law. This states that the frequency of a word in a language is inversely proportional to it's ranking when the words are ordered by frequency. So we would expect the most frequent word to be twice as common as the second most frequent word, and three times as common as the third most frequent word. The ramification of this is that the differences in frequencies for the more common words will likely contribute a larger amount to the total delta score.

We therefore standardise the score for each token \\(t_i\\) such that it has a mean of 0 and standard deviation of 1 over each document. We do this by calculating the frequency of a token in each corpus document \\(A_j\\). Then we take the mean and standard deviation of these frequencies - denote these as \\(\mu_i\\) and \\(\sigma_i\\), respectively. Finally, we define

$$ z_i(B_j) := \frac{f_i(B_j) - \mu_j}{\sigma_j}$$

A> Question for author: Why give equal weight to each word?

Finally, we define the refined version of the delta score:

$$\Delta(Q, B_j) := \frac{1}{N} \sum_{1 \leq i \leq N} |z_i(Q) - z_i(B_j)|$$

We look for the  author corpus with the smallest \\(\Delta\\).

The results of this technique is that every one of the seven Ferrante novels is closest to the Domenico Starnone corpus for each value of \\(N\\) (the number of tokens to use) of 100, 200, 300, 400, 500, 1000, and 2000.

>https://watermark.silverchair.com/fqx023.pdf?token=AQECAHi208BE49Ooan9kkhW_Ercy7Dm3ZL_9Cf3qfKAc485ysgAAAaowggGmBgkqhkiG9w0BBwagggGXMIIBkwIBADCCAYwGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMQ9Jr9jjy1UKYouS0AgEQgIIBXVQgBsu3_mR4YXAHlOKo3w9_u2UbMlIbQ4H0B573NI1GpQl5uXqOnb33dUFdggw3ojMwbRiHNb6nhKlfRVsgk_0Dh9-EE30YCND7mZxKYFkNHd--k5LwS1DQ49a5GJFIKWxLpYCSQ_DDKmG19TtI7syQ60hpkwQX8FB-QMEnG0EzfO0kwd2K2lkpFEQyGV9GuUyHlf6bGP0WGhD5pUVnO44Y9ML7p0cbO0fPfEpQCEAsPolRXbtAG62Vorq63Q-rJd0_gFg2CI4ucUfh0mfJ_9AZjRIOyw68h5iusuoWiC18EQmWf2NQqPX6qPLZ35TKy4owDK1dy3-5_g6rjXKiPGe83VK8aErPmjqvhoIh0RhAwdYtnwmHvh4E-iOxrUg6VbFqrL-aImDJK-MjmhFCHJfWkccRQm8fawOfyosUnXn3wtqqBKh6U-WAAjXrDuW7GkWR8OTCiLFX87IIwgU

ground-breaking!

### Labbé's distance

The second technique employed is using a distance defined by Dominique Labbé in a paper called [_'Experiments on Authorship Attribution by Intertextual
Distance in English'_](https://halshs.archives-ouvertes.fr/halshs-00139070/document). Again, we try to define some some or distance between two texts. This time, the calculation is independent of the entire corpus (unlike Burrows' delta which standardised based on the entire corpus). It can be expressed in a simple formula. First, let the _absolute frequency_ of a token be the number of times a token appears in a text. Define it as

$$g_i(A_j) := |\{t : t \in A_j, t = t_i\}|$$

Suppose we want to compute the distance between two texts \\(A_j\\) and \\(A_k\\). Without loss of generality assume that \\(A_j\\) has less tokens  than \\(A_k\\) (i.e. it is a longer text). We define

$$g'_i(A_k) := |\{t : t \in A_j, t = t_i\}| \frac{|A_j|}{|A_k|}$$

to proportionalise the frequencies in \\(A_j\\). Then finally we define

$$D(A_j, A_k) := \frac{1}{2|A_j|} \sum_{1 \leq i \leq N} |g_i(A_j) - g'_i(A_k)|$$

A> Question for author: Does this use every term?

A> Question for author: Is this basically equivalent to our first attempt at defining \\(\Delta\\) above??

Talk about results here.

> ccording to the formalism described in [24], one can estimate the probability that Starnone is the author of Storia della bambina perduta (DocID = 52 in Table 1) with a probability of 0.99.  

Seems spurious! defined in https://onlinelibrary.wiley.com/doi/pdf/10.1002/asi.23455


### Nearest shruken centroids
Finally, we introduce the


## Conclusion

Morality?
https://www.npr.org/sections/thetwo-way/2016/10/03/496406869/for-literary-world-unmasking-elena-ferrantes-not-a-scoop-its-a-disgrace

Gender?
https://www.harpersbazaar.com/culture/art-books-music/a21803/my-brilliant-friend-tv-show-male-director/


Closed set?
Misapplying a Closed-Set Technique
for an Open-Set Problem
In their study, Criddle and associates treat the
set of candidate authors as a “closed set,” assuming
that they knew with certainty that the true
author was one of the authors in their candidate
set. Although such an assumption would
be appropriate when using NSC in the genomic
studies for which it was originally developed,
this is not appropriate in most authorship attribution
studies. The case of The Federalist Papers is
a situation where the true author was known to
be in the candidate set—the twelve disputed articles
were written by either Alexander Hamilton
or James Madison, and by no one else. Such a
well-defined closed-set problem as The Federalist
Papers is a rarity in authorship attribution studies.
https://publications.mi.byu.edu/publications/review/23/1/S00007-51769fad6dedc7Fields.pdf

Confusing “Closest” to Mean “Close”
The logic of Criddle and associates’ approach
is no different than asking, “Choosing among
Boston, New York, and Chicago, which city is
closest to Los Angeles?” and then, upon finding
that there is a 99 percent probability that Chicago
is the closest, concluding that “Chicago is the city
in the United States that is closest to Los Angeles.”
https://publications.mi.byu.edu/publications/review/23/1/S00007-51769fad6dedc7Fields.pdf

https://www.nytimes.com/2018/02/07/books/plagiarism-software-unveils-a-new-source-for-11-of-shakespeares-plays.html
