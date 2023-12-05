This is a "roadmap" to possible future development of the network rewriting completion utility.


Short-term improvements
=======================
* `network` package: Procedures to decide whether networks and ambiguities are plane, to support working with a PRO rather than a PROP. **(DONE)**
* `cmplutil2.dtx`: Generalise fix for avoiding Apple's build of sqlite3 package. **(NEEDS TESTING)**
* `cmplutil1.dtx`: Include instructions in utility, to better support using this as a showcase for newcomers.
* `cmplutil2.dtx`: Provide a "reduce to normal form" operation that can work on linear combinations that did not come from wanting to resolve an ambiguity.

Non-hacker usability
====================

Sadhanandh Vishwanath has enthusiastically suggested developing the completion utility into a tool usable for diagrammatic calculations in (amongst other things) representation theory. The big hurdle to overcome for this is that usability has to be seen from the point of view of someone who is not hacking the source code, which means there must be a (mostly) programming-free user interface. Which are the pieces that would be needed to make that a reality?


Signature editor
----------------

There would pretty much have to be a point-and-click interface for editing the signature: naming operations (vertex types), specifying arity and coarity (that's merely a pair of [spinboxes](https://www.tcl.tk/man/tcl8.6/TkCmd/ttk_spinbox.html)), and selecting graphical elements for the appearance. The latter is a point where you can sink arbitrarily much development effort, and it can be easy to get carried away. It is also a point that doesn't really add to the scientific merits of the utility, but could well be important for its appeal.

A reasonable starting point could be that a vertex has a basic shape: circle, rectangle, or custom. For the first two, port positions and directions could be calculated automatically based on arity/coarity and basic size. (There's no reason to hardwire the traditional radius of 8 pixels.) For custom shapes, this would be manually edited (click and drag isn't hard in Tk, but the first time one codes it, it still takes getting used to). And regardless of shape, one would like to be able to add extra graphical elements (for example text).

It might also be useful to have some predefined signatures available, that the user can choose among (and then further modify); this would help showcase the possibilities.


Coefficient ring editor
-----------------------

Present interface for this is pure programming: you have to provide a command prefix implementing necessary operations in the ring. (Making new rules requires dividing by coefficient of leading term, so to be sure you need a field.) That's about as user-unfriendly as it can be (but completely general).

Minimal user interface would be to have a popup menu with some basic choices: ℚ and ℤ/p are obvious (the latter requires a box where one can type the p); one would also want the option of a "custom implementation" to allow for rings the point-and-click interface does not recognise.

It gets more complicated if we want to support field extensions. Transcendental field extensions are just fractions of elements from a polynomial ring, and the pieces of that construction are available. (Need to check what polynomial ring implementations support a GCD operation. Come to think of it, having a GCD probably means we need to do it with univariate polynomials, and nest the construction if the transcendence degree is larger than 1. This also suggests using a dense list encoding for the polynomials, which should help keeping the UI concise; for multivariate polynomials in general there are lots of encoding variants, which would make for a rather complicated user interface if offering alternatives.)

Algebraic field extensions are in one sense just polynomials modulo a given polynomial; I'm not sure the latter is already available, but at a principal level it's the same algorithms as for integers modulo n, executed in a different ring. The main complication would be how to enter the polynomial that we extend with the zeroes of. (It would be wise to verify that it is irreducible, but implementing that in general is nontrivial.)

A special case is the finite fields GF(p^n). These are algebraic extensions, and one can efficiently find an irreducible polynomial by picking one at random and then checking whether it is coprime to x^{p^k}-x for 1≤k≤n/2. For interoperability it might however be best to use the [Conway polynomials](https://openmath.org/cd/finfield1.html#conway_polynomial).

### What to store?

An interesting issue is what to store in the database file. The historical approach (not necessarily fully implemented) is to store the actual command prefix for the coefficient ring; in principle that is all the utility needs. It might however be more sane to store some sort of description of it, since that would allow printing some sort of presentation of what ring is used in a given database. (If returning months or years later, looking for the records from a specific calculation, it is *much* better if one can determine the coefficient ring without having to reverse engineer its implementation.)

### Expressing coefficients

Users will at times need to enter explicit coefficient values. Right now that has to be done by giving the internal representation of that value, which works when your coefficient ring is just ℤ/32003, but would start looking very awkward as soon as you go beyond that. For example, in ℚ(q) the element 4/3-2q would probably be encoded as `{{4 3} {-2 1}} {{1 1}}` (for (4/3*q^0+-2/1*q^1)/(1/1*q^0)).

A more colloquial way of writing coefficients would be desirable, but is perhaps not top priority.

### Presentation of coefficients

Similar to the previos issue, but distinct, is the matter of how to generate a (LaTeX or MathML) *presentation* of computed coefficients. In principle this can be solved in a universal manner by transforming values: (internal rep.) -> OpenMath (abstract) -> Content MathML -> Presentation MathML and then optionally on to LaTeX; each step in that chain have been implemented (at some point), but whether we can get those pieces together and run them today is another matter.

Some of the existing code for exporting results has options that let you plug in a custom formatter for coefficients, but the default is mostly to just dump the internal representation (because that works fine for integers modulo p).


Freezing signature and coefficient ring
---------------------------------------

It should be observed that changing signature or coefficient ring would at the very least require most tables in the database to be rebuilt, so essentially these should be treated as locked once set.

The issue with the coefficient ring is of course that changing this invalidates all coefficients already in the `ru1es` or `am6iguties` tables, because the internal representations probably changed. Mapping coefficients over to a new ring is possible, but not entirely trivial; providing such an operation is low priority.

The issue with the signature is that any change to the formal signature — even adding new vertices while leaving the old ones as they were — will change the network profiles. This requires the `ru1es` table to be rebuilt with a different number of columns. Changing only the appearance would be fine, however.

Come to think about it, freezing could be a side-effect of opening a database file. A signature or coefficient ring description is a fairly small amount of data, so there is no reason not to support keeping several in the UI. Only when creating a new database file would the user be asked to choose a signature and coefficient ring.


Axiom editor
------------

Like signatures, first-time users would likely want to play around with building networks in a point-and-click interface: each vertex type (`cross` vertex, `m` vertex, and so on) is shown as a separate "button", and clicking that inserts one vertex of that type. Like the formula editors in word procesors, it is however likely that this will get tedious after a while. Then the scan-list format should be provided as the quicker alternative, especially if one can get the scan-lists rendered in real time. Indeed, one way to foster this transition is to have the point-and-click interface work by way of scan-lists: clicking a button only causes the vertex name to be inserted into a scan-list, shown in a text widget below the network being built, and then the scan-list is parsed to produce the network being graphically shown.

A hurdle for this is that one does not want the layout of the network to change unexpectedly when adding stuff to it (something that the traditional layout generation could sometimes do). The `network::rich::construct` procedure (unclear at the moment if implementation of it got finished) is a sibling of `network::pure::construct` which also computes a network layout from a scan-list.

Axioms being linear combinations of networks, there would also need to be a way of specifying coefficients here (and also feedback lists). Editing/entering linear combinations of networks is indeed a task that should be useful more generally than for just providing the axioms, but for the completion utility it is where we first this.


Ordering editor
---------------

Specifying the ordering is the part of the completion utility which currently has the *worst* user interface: you have to implement computing and comparing of comparison keys, from scratch. This is in part due to the possibilities available not having been well understood when the utility got implemented.

In practice, all (or almost all) comparison implementations I've used have followed a simple pattern: first the network has been evaluated in a nice PROP with strictly compatible ordering, then the resulting PROP element has been flattened into a list of simple elements, and that list is made one block in the comparison key. If that is not sufficient then do it again, with a different PROP or the same PROP but different values for the vertices, providing another block of the comparison key; repeat until satisfied. There is certainly ample opportunity for systematising this.

At the top level, the key consists of blocks. Each block might be computed in a separate way, but evaluate-in-PROP-and-flatten is definitely one way which is useful. The first data needed here is which PROP to evaluate in; the standard choice would be the biaffine PROP over an ordered semiring. The basic choice for that semiring is ℕ (which essentially gives us ordering via generalised path-counting), but I seem to recall having used ℝ (to be precise, nonnegative floats) or even 2×2 matrices over ℝ on one occasion. The choice of PROP is somewhat linked to how to flatten its elements; for a matrix PROP that could be into the flat list of all the matrix elements. For tricky semirings, one may however wish to flatten those further; possibly the proper model is that there can be several levels to the PROP construction, and correspondingly several levels to the flattening. (Exact design merits further thought.)

There is also the matter of how to specify how vertex types (generators of the free PROP) map to concrete elements in the ordered PROP. Fairly graphical interfaces (e.g. an entry box for every element of the matrix) are possible, but probably rather cumbersome. An alternative is a text widget into which one types the PROP elements, but is this intuitive enough for non-hackers? Having one widget for multiple elements does however simplify copying data, e.g. if several rows in a matrix should be equal.

Further on, one might wish to examine using other PROPs for ordering. Might the Hom PROP (so: matrices with the Kronecker product as ⊗) be useful? Downside is that the number of matrix elements grow exponentially with arity and coarity in this representation. What about the connectivity PROP? Or that "heat" construction by (if memory serves) some French guy? Knot theory and related areas of mathematics may also provide constructions that could be viewed as defining ordered PROPs; this bears looking into.


Integration with Python
-----------------------

It might be worth looking into supporting callbacks to Python (via tkinter or similar) for custom operations, since users with *some* programming experience are more likely to know Python than Tcl. The main limitation here is that data would likely have to be **fully serialised** when passing from one language to the other. Tcl does that natively (because [Everything Is A String](https://wiki.tcl-lang.org/page/everything+is+a+string)), but on the Python side this could be unfamiliar.

Concretely, in Sage e.g. polynomials are objects which remember which ring they belong to and behave accordingly. It is not obvious that Python would preserve this information when serialising, but on the other hand there should for any callback from Tcl be a definite ring to which we expect the operands to belong, so it boils down to deserialising into the right kind of object.


Export
------

One mode of data export, for which there already exists procedures, is for the proofs of derived rules and ambiguity resolutions. That currently requires typing commands, but could be provided as GUI commands.

Another mode of data export might be of equations. It is not uncommon to first set up a system of axioms with undetermined coefficients and later decide that these have to be so that certain ambiguities resolve, which they would do if the remaining coefficients were all 0. The idea then is to make an equation system by equating all those coefficients to 0, and solve it to express some of these coefficients in terms of others, possibly with the intention of returning later with a smaller coefficient ring (because some transcendental extension steps have been changed into algebraic extensions). A catch is however that said equation system could be rather large, so one might want to process it further using a different computer algebra system. This calls for exporting the equations in a *machine-readable* interchange format, which is not among what is currently implemented.


Further operations
------------------

It has been suggested that computing "multiplication tables" for networks modulo some rewrite system would be useful. That is certainly doable; the most difficult problem on a general level is likely how to enumerate the basis giving rows and columns of this table. (Examining all ways of extending each known basis element by a single vertex, and adding all irreducible monomials that show up to one's list of known basis elements, should however suffice.)


Other medium-term development
=============================

Network layouts
---------------

For drawing a network, it is necessary to devise a layout for it. The current method for this — where different layers express "opinions" about how neighbouring layers should be ordered, and those opinions propagate — is very much a heuristic, and sometimes its results are not aesthetically optimal. One particular pattern that shows up is that when very distant layers have conflicting opinions on how to order things, then the network is split into two "zones of influence" in which one opinion rules, and any permutation of edges happen at the very busy boundary between these zones. Not seldom a gradual transition from one opinion to the other would look better, but how to achieve that?

One partially implemented approach is based on minimising total squared length of edges (tension energy) under a continuous relaxation of the item positions. It needs some work on the continuous optimisation side (steepest descent is too naive, but conjugate gradient should be tried) and choice of barrier functions. Finding the global optimum is likely infeasible, but a local optimum might look optimal, and that is good enough; the problem of finding the best layout is anyway poorly specified, so anything we do will be a heuristic.

### Partially prescribed layouts

Regardless of what the main principle is for assigning network layouts, it would also be useful to have an option for explicitly prescribing the layout of a network region: it could be neat to make sure that the networks before and after a rewrite step have the same layout outside the affected part.

Combining that with a feature for interpolating between network layouts, one could even start turning network rewriting proofs into SVG animations; perhaps not scientifically useful, but eminent for popular science.


Better overlap estimates
------------------------

The completion utility is processing ambiguities in increasing order (increasing number of vertices in the underlying equality) because small order equalities are more likely to give rise to useful rewrite rules. Lazy generation of ambiguities, where we hold off on computing the ambiguities for a pair of rules until roughly when we would be ready to process such ambiguities, does however mean we don't actually know what order these ambiguities would be. The unknown factor is the size of the overlap, and presently that is estimated as the average size of an overlap for the rules in question, but we could do better.

The basic observation is that the left hand sides of rules tend to have specific *active regions* which form overlaps with other left hand sides. For two rules to form an overlap, they have to have matching but opposite active regions. What consitutes an active region depends on the whole population of rules, but it is quite straightforward during a completion to gather data on which networks emerge as the shapes of active regions, and in which rules. This can then be used to prioritise the queue of pairs to look at (`pa1rs` table), entirely as computations in the database.


Long-term theoretical developments
==================================
At present, the completion utility is (give or take a bit) based on the theoretical framework from [Network Rewriting I](http://arxiv.org/abs/1204.2421). There are certain limitations of this, which it would be good to go beyond.


Wrap ambiguities
----------------

It was already in Network Rewriting I observed that network rewriting, unlike classical string rewriting, admits a kind of ambiguity (*wrap* ambiguities) where the redexes are completely disjoint but still block each other because of how they change dependency structures. This is the reason that the present Diamond Lemma only applies for sharp rewrite systems, but that is a restriction one would like to lift. A first step towards this would be to enumerate also wrap ambiguities, which only arise between two non-sharp rules. (Needs to be proved.)

A wrap ambiguity is characterised by the feedbacks between the two left hand sides. One approach for enumerating them is to formulate the conditions characterising a wrap ambiguity as a SAT problem, and then use a SAT-solver to check if one arises. The whole thing boils down to statements about nilpotency of boolean matrices where some elements are unknown; this shouldn't be too bad (it has us encode boolean matrix multiplication as a constraint on boolean variables, but phrased in terms of repeated squaring for the nilpotency, we don't have to do very many matrix multiplications).

This very much ties into the problem of what the feedbacks *really* encode. Network Rewriting I interpreted them in terms of the dependency filtration of the free PROP, which from the algebraic point of view is a very neat package, but I am no longer convinced this is precisely the right thing for rewriting.


Context-dependent orderings
---------------------------

The theoretical requirement why the ordering must be (strictly) compatible with the PROP structure is that rewrite steps are supposed to map larger things to smaller — if they didn't then we wouldn't know whether reduction terminates — and we achieve this by requiring the left hand side of a rule to be strictly larger than all terms in the right hand side. A failure of the ordering to be strictly compatible could result in comparisons that get reversed when placed in a troublesome context, and thus in the action of a rule in some instance being to map a smaller thing to something larger! But (strict) compatibility is not without cost.

Beacuse permutations are part of a PROP, and because each of these permutations have finite order, we cannot have μ < μ∘σ for any permutation σ if < is strictly compatible. This is troublesome for axioms such as the Jacobi identity in a Lie algebra, since all three terms in that are equal up to permutation of the arguments; the three terms are incomparable, so it is impossible to single out one term for the left hand side of a rule. Indeed, the problem arises already for commutativity (or anticommutativity) of multiplication! This is also the reason an ordering for arity or coarity ≥2 *must not* depend on the order of the legs: there is always some permutation (some context) that reverses that. Thus we cannot evaluate networks in some matrix PROP and then compare the values using the Occidental matrix order — first compare position (1,1), if that is equal then look at position (1,2), etc. — because permutations could swap any matrix element into the (1,1) position; the best we can do is use the standard matrix order (in every position we separately have ≤), which is what we get from making one comparison block out of all the matrix elements.

An alternative approach for rewriting which sidesteps these issues is **unfailing completion**, mostly studied within term rewriting. The idea is to give up on independence of context, and instead treat rules as conditional: a rule only applies in contexts where its left hand side is larger than all terms in the right hand side. On the other hand, one equality may give rise to multiple rules (each with a different term singled out as the left hand side), so regardless of context there could always be some way of applying that equality. With unfailing completion, we could have a total order even for network rewriting, which is nice if you want to deal with identities such as commutativity or Jacobi.

The price to pay for context dependence lies in ambiguity resolution: it's nice if an ambiguity resolves with no context (identity context map), but that doesn't tell us much about the general situation, because there could be contexts in which some of the rewrite steps are forbidden — then what do we do? In the concrete situation, we would of course try to find a different resolution which would work in that context; we may succeed and be happy, or fail and discover a new nontrivial equality, just as in normal completion. To be able to claim that we have a complete rewrite system, we must however for any context have found a resolution which applies there. Is that feasible? Actually yes, because there is far less variation in what a resolution may look like than in what the contexts can be; there are only so many equalities, and for each only so many different ways in which it might potentially get applied. (Compare Gröbner walk in the commutative algebra setting.) The problem is how to know that you've considered them all.

For operadic (coarity 1) equalities and an ordering based on the e.g. the biaffine PROP, that is actually not too hard, because the problem of how to find a context where a specific rewrite step is not allowed (but some others are) can be turned into a linear programming problem — solving those would require a new library in the utility, but calls to its operations finish in polynomial time, so overall feasibility is not impaired. For convex network equalities, we instead have to solve a (not positive definite) bilinear programming problem, which in general is NP-hard (though chances are good that it is "only" NP-complete). Nonconvex ambiguities would in principle raise the degree even further, but on the other hand bilinear problems can encode general polynomial inequalities, so bilinear is in principle sufficient.

