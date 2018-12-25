Title: YouCompleteMe on Macports Vim
Modified: 2018-12-25
Tags: macports, vim
Authors: Pedro F. H.
Summary: How to get YouCompleteMe to work with Macports Vim
Status: published

Here are some notes on how I got [YouCompleteMe][] to work on [MacPorts][]
[Vim][] installation.  If you have not heard of _YouCompleteMe_, check out
this [YouCompleteMe demo][] really quick.  It is a:

> fast, as-you-type, fuzzy-search code completion engine for Vim.


### Instructions

At a very high level:

  1. Make sure that _MacPorts_ `vim` and `python` are found before the _OS X_
     versions.  This requires updating your `PATH` environment variable.
  2. `python` is symlinked to the correct version.  `python35` in this case.
  3. `vim` is compiled with _Python_ support.  _MacPorts_ does not do this by
     default.
  4. Install _YouCompleteMe_.

Detailed instructions provided in the following sections.

My setup at time of writing this post:

  - OS X 10.14.2
  - MacPorts 2.5.4
  - [YouCompleteMe commit 7997fc5][]
  - Vim 8.1
  - Python 3.7.1 (this should work with 2.7)


#### Setting up your environment PATH

In order for this to work the _MacPorts_ `bin` directory has to be high up on
the `PATH` list.  The `PATH` needs to be updated with something like this:

```bash
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
```

This will allow for the _MacPorts_ versions of `vim` and `python` to be found
before the locally installed _OS X_ versions are.  There are various ways of
doing this, I personally maintain my `PATH` environment variable in
`~/.profile` with a block like this in it:

```bash
# PATH variable for use with MacPorts.
if [ -f "/opt/local/bin/port" ] ; then
  export PATH=/opt/local/libexec/gnubin:/opt/local/bin:/opt/local/sbin:$PATH
  export MANPATH=/opt/local/share/man:$MANPATH
fi
```

For more on configuring environment variables refer to [MacPorts and the
Shell][].


#### Installing MacPorts Python

The key takeaway here is using `port select` to maintain the symlinks pointing
the actual versions of `python` being used.

```bash
$ sudo port install python37 py37-pip py37-gnureadline
$ sudo port select --set python python37
$ sudo port select --set python3 python37
$ sudo port select --set pip pip37
```

In this case executing `python` and `python3` point to the `python35`
executable.  `pip` is symlinked similarly.

If you are not familiar with `port select`, try `port help select` and
`port select --summary`.  The latter will provide a list of all _MacPorts_
selection groups.


#### Installing MacPorts Vim

_MacPorts_ `vim` does not come with _Python_ support by default.  This is
simple to remedy using [MacPorts variants][].  Just reinstall _Vim_ with:

```bash
$ sudo port install vim +python37 +huge
```

To get a full list of features that `vim` is compiled with execute
`vim --version`


#### Installing YouCompleteMe

Assuming you manage your _Vim_ plugins using something like [Pathogen][] or
[Vundle][], clone the _YouCompleteMe_ repo from _GitHub_:

```bash
$ cd ~/.vim/bundle
$ git clone https://github.com/Valloric/YouCompleteMe.git
$ cd ~/.vim/bundle/YouCompleteMe/
$ git submodule update --init --recursive
```

Now to install the compiled components of _YouCompleteMe_.  The installation is
done with `install.py`, and not `install.sh`.  The latter is being deprecated
and defaults to a _Python 2.x_ installation:

```bash
$ ./install.py --clang-completer
```


### Further reading

This post is an elaboration on the following.  I found them while trying to
figure out how to get _YouCompleteMe_ working on my configuration.  Moving to
_MacVim_ was not really an option for me:

  - [HOWTO Install on MacPorts][].
  - [YouCompleteMe Issue #1351][].

These may be helpful as well:

  - [YouCompleteMe][] - "YouCompleteMe is a fast, as-you-type, fuzzy-search
    code completion engine for Vim. It has several completion engines."
    - [YouCompleteMe demo][] - For a quick demonstration of what it can do.  It
      is quite impressive.
    - [YouCompleteMe on GitHub][]
  - [MacPorts][] - "The MacPorts Project is an open-source community initiative
    to design an easy-to-use system for compiling, installing, and upgrading
    either command-line, X11 or Aqua based open-source software on the Mac
    operating system."
  - [Vim][] - "Vim is a highly configurable text editor built to make creating
    and changing any kind of text very efficient. It is included as "vi" with
    most UNIX systems and with Apple OS X."
  - [MacVim][] - "Vim - the text editor - for Mac OS X."



[MacPorts]: https://www.macports.org/
    (The MacPorts Project Official Homepage)

[YouCompleteMe]: https://valloric.github.io/YouCompleteMe/
    (The YouCompleteMe homepage)
[YouCompleteMe on GitHub]: https://github.com/Valloric/YouCompleteMe
[YouCompleteMe demo]: https://github.com/Valloric/YouCompleteMe#intro
[YouCompleteMe commit 7997fc5]: https://github.com/Valloric/YouCompleteMe/commit/7997fc5536e8220ed2798c5522a1eb4421577fa2

[MacVim]: http://macvim-dev.github.io/macvim/
    (MacVim homepage)
[MacPorts variants]: https://guide.macports.org/chunked/using.variants.html
    (Documentation on MacPorts variants)
[MacPorts and the Shell]: https://guide.macports.org/chunked/installing.shell.html
    (MacPorts shell configuration)

[Vim]: http://www.vim.org/
    (The Vim homepage)
[Vundle]: https://github.com/VundleVim/Vundle.vim
[Pathogen]: https://github.com/tpope/vim-pathogen

[HOWTO Install on MacPorts]: https://groups.google.com/forum/m/#!topic/ycm-users/gWRjIlyJr30
    (YouCompleteMe user's Google Group)
[YouCompleteMe Issue #1351]: https://github.com/Valloric/YouCompleteMe/issues/1351#issuecomment-98040965
    (GitHub Issue comment)

