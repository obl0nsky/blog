---
title: "The Loopix Anonymity System (Septimus I)"
date: 2018-01-25
tags: septimus
draft: false
markup: "mmark"
---

The paper we shall be looking at in this post will be: [The Loopix Anonymity System](https://arxiv.org/pdf/1703.00536.pdf).

## Mix Networks
To understand _Loopix_, first we must understand _mix networks_, a concept was first introduced in a [1981 paper](https://www.cs.umd.edu/class/spring2015/cmsc414/papers/chaum-mix.pdf) by David Chaum. The matter concerned is this. If Alice wants to send a secret message to Bob, there are numerous ways (of varying sophistication) in which she can do so. However, suppose in addition that she doesn't want Bob to know that it was _her_ that sent it. Traditional encryption models do not offer such sender anonymity. A _mix network_ is a system designed to offer this additional property. It will also allow Bob to send a message back to the unknown-to-him sender (in our case Alice).

### Assumptions and notation

- There are \\(N\\) participants in our network. Call them \\(A_1 ... A_N\\).
- Each participant has a corresponding public encryption function \\(encrypt_i\\) which is known by all the participants and can be used to encrypt a message intended to be read by participant \\(i\\).
- Each participant has a private decryption function \\(decrypt_i\\) which is known only to them and can be used to decrypt messages which were encrypted with the corresponding encryption function \\(encrypt_i\\). We have \\(decrypt_i \circ encrypt_i = id\\).
- There are \\(K\\) _mix nodes_. Call them \\(M_1...M_K\\). These also have public encryption and private decryption functions as described above. Call the encryption functions \\(mixEncrypt_i\\) and the decryption functions \\(mixDecrypt_i\\).

### Mix nodes

Suppose \\(A_i\\) wants to send a message \\(s\\) to \\(A_j\\). If they didn't care about anonymity. Since they have access to \\(encrypt_j\\) they could just send \\(encrypt_j(s)\\) to \\(i\\). Participant \\(j\\) can then run \\(decrypt_j\\) on that encrypted message to retrieve the original message. Since only \\(j\\) has access to the decryption function, if an adverse participant got hold of the encrypted message, they wouldn't be able to decode it (with come caveats[^1]). This is classic [public key cryptography](https://en.wikipedia.org/wiki/Public-key_cryptography).

Now suppose that \\(A_i\\) does not want \\(A_j\\) to know that she was the one who sent the message. How can we ensure that? To do so, we introduce _mix nodes_ which act as a layer of indirection.

\\(A_i\\) can send an encrypted message to a mix node (\\(M_k\\), say) which when unencrypted contains the name of the recipient (in our case \\(A_j\\)) and an encrypted message for \\(A_j\\). When the mix node receives this message, it will then forward on the inner-encrypted message to the specified recipient. The recipient can then decrypt this message and see the original. Because any participant could've given the message to the mix node, \\(A_j\\) cannot tell who sent the message. This is analogous to how the post office works (at least in the UK), albeit without the encryption. Anyone can post a letter. The Royal Mail will receive the letter, and forward it on to the specified address. The recipient does not know who sent it. Concretely,

$$ A_i \xrightarrow{mixEncrypt_k(A_j, encrypt_j(s))} M_k \xrightarrow{encrypt_j(s)} A_j.$$


### Corrupted mix nodes
However, there is a problem with this. What happens if the mix node is corrupted in someway. Suppose an adversary can see which things are coming in and out of a mix node. If a message is passed to \\(A_j\\) quickly after one was received from \\(A_i\\) then it's a good guess that \\(A_i\\) is sending a message to \\(A_j\\).

#### Batches
One amelioration to this is for mix nodes to batch the sending of messages. For example, it may wait until it gets 20 message, randomly order them[^2], then send them out.

Note that if we send the same message twice (or more), we also lose the anonymity. This is because an adversary who can observe the direction and content of all the traffic in the network could follow the path of the 'double'. The batching adds the benefit that we can't know which output corresponds to which input, but if an adversary sees a 'double' message go in to a mix node, it can match it up with where a double message goes out. To avoid this issue, we can configure the mix nodes to drop any duplicate messages.

#### Cascades
Instead of just passing a message through one mix node, we can pass it through many. Chaum calls this a _cascade_. We extend our previous model by allowing the address of the unencrypted message we send to be _another_ mix node. Thus we wrap the encrypted messages like russian dolls. For example if we want to send to mix node \\(k\\) then to mix node \\(l\\) we might have:

$$ A_i \xrightarrow{mixEncrypt_k(M_l, mixEncrypt_l(A_j, encrypt_j(s)))} M_k \xrightarrow{mixEncrypt_l(A_j, encrypt_j(s))} M_l \xrightarrow{encrypt_j(s)} A_j.$$

If an adversary controlled a mix node, they might be able to tell that someone sent a message \\(M_k\\) can tell that \\(A_i\\) sent a message above), or someone received a message \\(M_l\\) can tell that \\(A_j\\) is receiving a message above), but never _both_ for the same message if the message passes through more than one mix node.


### Replies
What we have so far is an effective way to send a message anonymously to another participant in the network. What about if \\(A_j\\) wants to send a reply to \\(A_i\\) (despite not knowing their identity). For example, they might want to send a note confirming they have received the original message.

To do this, \\(A_i\\) can include in its message to \\(A_j\\):

- A one-time encrypt function (\\(encrypt\\), say) of which \\(A_i\\) can decode.
- A mix node to use (\\(M_k\\), say)
- A pointer to its own address, encrypted using the mix node

With this information, \\(A_j\\) can compose a response (\\(r\\), say), encrypt it using one-time encrypt function, chuck it in a 2-tuple with the encrypted address to the sender, encrypt that tuple using \\(mixEncrypt_k\\) and finally sending that to \\(M_k\\). When the mix node receives this, it can decrypt the message, (note it is still encrypted using the one-time key), decrypt the inner encrypted pointer to the sender, and finally send the encrypted method to the address just revealed. As \\(A_i\\) created the one-time \\(encrypt\\) function, she can decode the message. Visually:

$$ A_i \xrightarrow{mixEncrypt_k(A_j, encrypt_j(s), encrypt, mixEncrypt_k(A_i))} M_k \xrightarrow{encrypt_j(s, encrypt, mixEncrypt_k(A_i))} A_j.$$

and

$$ A_i \xleftarrow{encrypt(r)} M_k \xleftarrow{mixEncrypt_k(encrypt(r), mixEncrypt_k(A_i))} A_j.$$

A> Question for author: Where does this simple technique breakdown? (the paper and wikipedia have a more convoluted expositions involving another private key)

A> Question for author: Is this extensible to use a cascade of mix nodes on the return leg?

## Loopix

There are still several weaknesses with the system described above. Loopix (_Ania Piotrowska et al_, 2017) identifies these and introduces remedies.

### Sender online unobservability
In the original design. An external observer of the traffic (denoted in the paper by the term _global passive adversary_ or _GPA_) flow in the system can see whenever a participant is sending a message. Can we improve the system to give the sender assurance that not only will no-one be able to tell who they are sending a message to, but that they are sending a message at all?

Yes we can. The sender can send out 'fake' messages at regular intervals. These fake messages will be assigned a random cascade path as is done with real messages, and have a special flag telling the final recipient to discard it. As the content of both fake and real messages will look like encrypted noise to a GPA, it will not be able to distinguish between the fake messages and the real messages. We call these fake messages _cover traffic_.

### Receiver unobservability
Another weakness in the original design is that a GPA can see when a participant receives a message. _Loopix_ solves this with the introduction of _providers_. These are nodes which act as an intermediary between the mix nodes and the participants. They are stateful. When they receive a message, they will store the message (now wrapped in only one layer of encryption) in a letterbox for the intended recipient. Participants will poll providers for their messages. Providers will always return a constant number of messages, padding the response with fake messages if there aren't enough in their letterbox. Once again, a GPA cannot tell if the messages are real or fake.

### High latency
In the original design, a mix node would have to wait until it received a certain number of messages before releasing a batch. If there was only one messages per 10 minutes and mix nodes released messages in batches of 7, then the first message in a mix node would have to wait around an hour before being passed on.

Another benefit of the _cover traffic_ described above is that it greatly alleviates this problem. An aspect of _Loopix_ hitherto undescribed is that the mix nodes act _continuously_ rather than _discretely_ (sending messages in batches).

Every message received by a mix node also carries a length of time to delay before passing it on. This length of time is chosen independently for each 'hop' by selecting from an exponential variable with parameter \\(\mu\\), where \\(\mu\\) is a global value throughout the entire system. The choice of selecting from an exponential variable has a very useful property: the _memoryless property_. This ensures that if there are N messages waiting in a mix node, a GPA does not have any information about which message will come out next _regardless_ of the order in which they arrived.

The parameter \\(\mu\\) can be tuned to ensure latency is low.


### (n-1) Attack
If we have a strong adversary who can control traffic flow in the network, new attack vectors become open to them. One such vector is an _(n-1) attack_. This is when the adversary will block all but one target message from entering a mix node. They can then observe the message coming out of the mix node and track it's path through the system. To defend against this, Loopix has the mix nodes send _loop traffic_ at regular intervals. These are cover messages which start and end at the same mix node. If the mix node detects that it has stopped receiving the loop traffic it is sending to itself, it can either stop emitting messages altogether, or generate cover traffic so that once again the target message is 'lost'.


A> Question for the author: Suppose there was a very popular recipient. Their provider may receive a significantly disproportionate amount of messages. An GPA could see this and infer that at least one user of that provider is receiving

## Conclusion
The repeated idea behind the improvements of Loopix upon the original design is the adding of noise where none was originally present, and in doing so reducing the information available to an observer of the system.

One might be reminded of the following:

This [passage](https://www.fanfiction.net/s/5782108/72/Harry-Potter-and-the-Methods-of-Rationality) in HPMOR:

> "Well," Harry said, as their shoes pattered across the tiles, "I can't just go around saying 'no' every time someone asks me about something I haven't done. I mean, suppose someone asks me, 'Harry, did you pull the prank with the invisible paint?' and I say 'No' and then they say 'Harry, do you know who messed with the Gryffindor Seeker's broomstick?' and I say 'I refuse to answer that question.' It's sort of a giveaway."

The [theories](https://www.youtube.com/watch?v=Y5ubluwNkqg) on Russian politician Vladislav Surkov's _managed democracies_:

> Surkov turned Russian politics into a bewildering, constantly changing piece of theater. He sponsored all kinds of groups, from neo-Nazi skinheads to liberal human rights groups. He even backed parties that were opposed to President Putin.

> But the key thing was, that Surkov then let it be known that this was what he was doing, which meant that no one was sure what was real or fake. As one journalist put it: "It is a strategy of power that keeps any opposition constantly confused."

Military transport [techniques](https://www.freehaven.net/anonbib/cache/entropist.pdf):

> [I]n the 1970s the United States and the Soviet Union sought to limit the number of nuclear missiles they both had through cooperation and inspection while maintaining security guarantees. A large part of one of the major initiatives involved shuttling Minuteman missiles about in a field of silos to preclude successful first-strike attacks directly on all available missiles. The plan also included techniques for communicating to the adversary an authenticated, integrity-protected report from each silo. The report indicated whether a missile was in the silo or not, but without the adversary being able to determine which silo the report was from (except by silo-unique but random identifier). In a field of 1000 missile silos, the adversary could be sure that exactly 100 would be occupied but would not know which ones were occupied. Note that this anonymity system used “dummy packets” in the form of huge “transportainer” trucks continually shuttling either actual missiles or dummy loads between silos. Talk about system overhead!


## Sources

- [Untraceable Electronic Mail, Return Addresses, and Digital Pseudonyms](https://www.cs.umd.edu/class/spring2015/cmsc414/papers/chaum-mix.pdf)
- [The Loopix Anonymity System](https://arxiv.org/pdf/1703.00536.pdf)
- [USENIX Security '17 - The Loopix Anonymity System](https://www.youtube.com/watch?v=R-yEqLX_UvI)



[^1]: In reality, an adversary could construct their own version of the decryption function by performing a [preimage attack](https://en.wikipedia.org/wiki/Preimage_attack). If they knew in advance what sort of message is likely to be sent from \\(i\\) to \\(j\\) then they could create a dictionary of encrypted values using the public encryption function of \\(j\\) and the corresponding raw message. When they intercept an encrypted message, they can see if it is present in their dictionary. A form of resistance against this sort of attack is to prepend a random string of known fixed sized to message that is being sent. The recipient can discard the nonsense prefix. This creates a lot of extra work for the adversary as they would have to compute the encrypted messages for a possibly infeasible amount of prefixes.
[^2]: In the original paper, it is suggested they are lexicographically sorted before sending out. Either will work!
