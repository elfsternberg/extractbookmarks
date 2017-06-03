Bookmark Extractors
===============================

These are two small, simple utilities for extracting Evernote (ENEX) and
Delicious bookmarks to Emacs ORG mode, written in Hy version 0.12.
These are fairly idiosyncratic; The Enex extractor assumes you have an
Enex file available for extraction; the Delicious extractor assumes you
have working access to your http://del.icio.us repository.

version number: 0.0.2
author: Elf M. Sternberg

Installation / Usage
--------------------

To use, clone the repo:

    $ git clone https://github.com/elfsternberg/extractbookmarks.git
    $ python setup.py install
    
Example
-------

$ hy ./extract-enex <path to Evernote archive>
$ hy ./extract-delicious 'http://del.icio.us/your-name?page=1' > Delicious.org

The Enex extraction will create a default Bookmarks.org file, with each
individual bookmark in its own slugified file.  Adjust at will.
