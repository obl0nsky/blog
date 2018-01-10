---
title: "The Loopix Anonymity System (Septimus 1)"
date: 2018-01-08T18:28:59Z
tags: septimus
draft: false
markup: "mmark"
---

The paper we shall be looking at in this post will be: [The Loopix Anonymity System](https://arxiv.org/pdf/1703.00536.pdf).

## Mix Networks
To understand _Loopix_, first we must understand _mix networks_, a concept was first introduced in a [1981 paper](https://www.cs.umd.edu/class/spring2015/cmsc414/papers/chaum-mix.pdf) by David Chaum. Suppose Alice wants to send a secret message to Bob. There are numerous ways (of varying sophistication) in which she can do so. However, suppose in addition that she doesn't want Bob to know that it was _her_ that sent it. Traditional encryption models do not offer such sender anonymity. A _mix network_ is a system designed to offer this additional property. It will also allow Bob to send a message back to the unknown-to-him sender (in our case Alice).

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

Note that if we send an identical message twice, we also lose the anonymity. This is because an adversary who can observe the direction and content of all the traffic in the network could just follow the 'double' path. The batching adds the benefit that we can't know which output corresponds to which input, but if an adversary sees a double message come in, it know that will match up with a double message going out. To avoid this issue, we can configure the mix nodes to drop any duplicate messages.

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

## Sources

- [Untraceable Electronic Mail, Return Addresses, and Digital Pseudonyms](https://www.cs.umd.edu/class/spring2015/cmsc414/papers/chaum-mix.pdf)
- [The Loopix Anonymity System](https://arxiv.org/pdf/1703.00536.pdf)
- [The Differences Between Onion Routing and Mix Networks](https://crypto.is/blog/mix_and_onion_networks)
- [Why I’m not an Entropist](https://www.freehaven.net/anonbib/cache/entropist.pdf)
- [Sleeping dogs lie on a bed of onions but wake
when mixed](https://petsymposium.org/2011/papers/hotpets11-final10Syverson.pdf)
- [From a Trickle to a Flood: Active Attacks on
Several Mix Types](https://www.freehaven.net/anonbib/cache/trickle02.pdf)


[^1]: In reality, an adversary could construct their own version of the decryption function by performing a [preimage attack](https://en.wikipedia.org/wiki/Preimage_attack). If they knew in advance what sort of message is likely to be sent from \\(i\\) to \\(j\\) then they could create a dictionary of encrypted values using the public encryption function of \\(j\\) and the corresponding raw message. When they intercept an encrypted message, they can see if it is present in their dictionary. A form of resistance against this sort of attack is to prepend a random string of known fixed sized to message that is being sent. The recipient can discard the nonsense prefix. This creates a lot of extra work for the adversary as they would have to compute the encrypted messages for a possibly infeasible amount of prefixes.
[^2]: In the original paper, it is suggested they are lexicographically sorted before sending out. Either will work!
