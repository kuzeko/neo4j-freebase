# Freebase Neo4j Importer
## Author [Matteo Lissandrini](https://disi.unitn.it/~lissandrini/)

## Set up Neo4j Server, and Load Cleaned Freebase Dump

This suite, downloads data from [The Freebase ExQ Data Dump](https://disi.unitn.it/~lissandrini/notes/freebase-data-dump.html), and loads it into a Neo4j server.

Nodes are of two types: **Entities** and **Types**, edges instead have around 4K alternatives.



## Instructions:


  0. Use `scripts/download.py` or manually download the required files, they are listed in `scripts/files.list`

  1. Use `scripts/preprocess.sh` to clean the file and produce the required `.csv` files in `./data`

  2. Use `scripts/build.sh` to build the docker images

  3. Use `scripts/run.sh -i` to import the data

  4. Use `scripts/run.sh -x` to index some basic properties

  5. USe `scripts/run.sh`  to start a server on localhost:7474


