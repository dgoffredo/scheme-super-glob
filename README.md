![Super Glob](super-glob.png)

scheme-super-glob
=================
Chicken Scheme module for extended path globbing

Why
---
I needed the equivalent of many shells' "brace expansion," e.g.

    /some/path/with/{this,or-this}/and{/maybe-this,}

expands to all of

    /some/path/with/this/and/maybe-this
    /some/path/with/this/and
    /some/path/with/or-this/and/maybe-this
    /some/path/with/or-this/and

In particular, I needed to do this when "globbing" (i.e. finding all paths that
match a pattern), and so I extended Chicken's `glob` procedure.

What
----
`scheme-super-glob` contains a Chicken Scheme file, `super-glob.scm`, which
contains a module, `super-glob`, which exports a procedure, `super-glob`.

How
---
Here's an example from the source:

    (define t "program")
    (super-glob `((? "/opt") "/xy" ("data" "logs") (? ,t) ,(conc t ".log*")))

might return something like (depending on what's sitting on the file system):

    ("/opt/xy/logs/program/program.log"
     "/xy/data/program.log.oldschool"
     "/xy/logs/program/program.log.normal"
     "/xy/logs/program/program.log.normal.gz")

More
----
See the [source code](super-glob.scm).  In particular, it describes the (tiny)
mini-language supported by `super-glob`.

`super-glob` depends on the [clojurian][clojurian] egg.

[clojurian]: http://wiki.call-cc.org/eggref/4/clojurian
