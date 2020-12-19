.. Faiss documentation master file, created by
   sphinx-quickstart on Tue Oct 20 17:21:19 2020.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

.. toctree::
   :maxdepth: 2
   :hidden:

   install
   tutorial/index
   api

Introduction
============

Faiss is a library for efficient similarity search and clustering of dense vectors. It contains algorithms that search in sets of vectors of any size, up to ones that possibly do not fit in RAM. It also contains supporting code for evaluation and parameter tuning. Faiss is written in C++ with complete wrappers for Python (versions 2 and 3). Some of the most useful algorithms are implemented on the GPU. It is developed by `Facebook AI Research <https://research.fb.com/category/facebook-ai-research-fair/>`_.

What is similarity search?
--------------------------

Given a set of vectors x_i in dimension d, Faiss build a data structure in RAM from it.
After the structure is constructed, when given a new vector x in dimension d it performs efficiently the operation:

.. math::
   j = argmin_i \lVert x - x_i \rVert

where :math:`\lVert\cdot\rVert` is the Euclidean distance (:math:`L^2`).

If Faiss terms, the data structure is an *index*, an object that has an *add* method to add :math:`x_i` vectors.
Note that the :math:`x_i`'s are assumed to be fixed.

Computing the argmin is the *search* operation on the index.

This is all what Faiss is about. It can also:

- return not just the nearest neighbor, but also the 2nd nearest, 3rd, ..., k-th nearest neighbor

- search several vectors at a time rather than one (batch processing). For many index types, this is faster than searching one vector after another

- trade precision for speed, ie. give an incorrect result 10% of the time with a method that's 10x faster or uses 10x less memory

- perform maximum inner product search :math:`argmax_i \langle x, x_i \rangle` instead of minimum Euclidean search. There is also limited support for other distances (L1, Linf, etc.).

- return all elements that are within a given radius of the query point (range search)

- store the index on disk rather than in RAM.

# Indices and tables

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
