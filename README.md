# QoS-route-distributing
With QoS(Quality of Service) constraints, find a relative optimal route for a given flow. Nov 2015 to Apr 2016. Project for H3C Router departement.

Q:What the problem detail is?
A:Everyone knows the shortest path problem and the solution O(n^2) algorithms. However in industrial field, most path problem includes some constraints.
Especially telecommunication routing problem, the data must be pass with QoS constraints. This muti-constrainted shortest path(MCSP) even constrainted path problem(CPP) has been prove
NP-hard and we provide an approximation algorithms which use the thinking of The Lagrange Multiplier to simplify it.

Given Network G(V,E) with each edge E having certain maxbandwidth&lossratio&delay&cost
data folw f(s,t) from s to t with certain bandwidth&maxlossratio&maxdelay
find a path p(s,v1,v2...,vm,t) with least cost sum(E(s->v1).cost,E(v1->v2).cost,...,E(vm->t))
and also with
f.bandwidth<max(maxbandwidth(p))
f.maxlossratio<1-product(1-lossratio(p))
f.maxdelay<sum(delay(p))


Q:Why Matlab?
A:My professors are all focus on mathematic part so that they can only read Matlab codes. But these code may look like C style(process-oriented) cuz I am just a green hand in Matlab.
I think you can treat them as C codes very easyily even you have never know Matlab grammar.

Q:Does this project include executable source code and Could this be used in the pratical problem?
A:Unfortunately, this project is only a simulation code for testing feasibility&complexity&efficiency of the algorithm provided and you cannot use it to solve pratical routing problem directly.
For the secrecy agreement, I can only share the simple version here. However, you can easily understand the core algorithm and use it into your own project.

Q:Any English documents?
A:These documents were writen for H3C engineers directly. To avoid from misunderstanding, we provide the Chinese version only.
I'm trying to translate them into English. But it will take a long time cuz I have to prepare for some tests foremost.
The comment part would be translated first for helping your code understanding.

For the limited English ability, spelling errors may appear in the names of variables or comments. Just ignore it.
