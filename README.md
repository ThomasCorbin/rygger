# Rygger

Rygger is just a gem that provides some unix-esque commands that I can use
on windows.   I'm in a position at work where I can't install cygwin on my
machine, but I could install ruby.  Go figure, but it let me practice some
ruby and write some of these utilities that I'm used to having around.
And they've been a lifesaver.

I'm also using this to stretch my ruby muscles and to write my first gem.

Rygger is in a fairly preliminary state, but I've found it immensely useful
as it is.   I can't say that anyone else would find it useful, but you're
welcome to do what you want with it.

A better choice for others would probably be [ack](http://betterthangrep.com/)
and Daniel Lucraft's [rak](https://github.com/danlucraft/rak).

The commands I have
------------

* rgrep       - sorta like grep, but recursive.  Not like ack.
* rfind       - sort of like find
* rtee        - like tee
* rcat        - like cat
* rtail       - like tail
* prpath      - prints out a PATH or CLASSPATH, which each path item on it's own row.

Installation
----------

1. git clone git@github.com:ThomasCorbin/rygger.git

I don't have this set up so that a simple "gem install" would enable
you to install it.  Other than a git clone, I haven't yet figured out a way
of installing Rygger.  I know that in a Gemfile you can refer to a a git
repository, but haven't figured out how to do that from the command line.

You could certainly make a bogus project and have a Gemfile that gets
Rygger from the git repository.

Shortcomings
------------

1.  _rgrep_ doesn't filter stdin, it can currently only find regular expressions
    in files.

1.  I'd like the command line flags to be consistent between the commands.

1.  I'd like _rtee_ to have the _-a_ flag.

1.  Slop doesn't seem to allow abbreviations for long flags.  For example,
    I can't use "--ve" instead of "--verbose".

1.  The code in _rgrep_ needs cleaning up and refactoring.

1.  There are no tests.

1.  I've never written a gem before.

1.  Some of the commands are extremely preliminary, so they don't
    have command line processing or share common code.

1.  I'm probably the only person who likes lolize so much.  If not for
    lolize, I like the colorize bit that shows the matched expressions
    in colors.


I got the code I used to start rgrep off the internet, will have to find out
where.  But all bugs and awkward interfaces are mine, not the original author's.

I found an rtail gem, but I'm also looking at James Edward Grey's elif library.
It's no longer maintained, as far as I can tell, but I'd like to compare the
two and see what I can learn.   He's working on an rcat, which I find very
interesting.

Installing locally
------------------

rake -T

rake install


License
----------

Use it, copy it, do what you want with it, but don't blame me for any problems.
