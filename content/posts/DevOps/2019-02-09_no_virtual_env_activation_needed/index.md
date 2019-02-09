Title: A simple pattern for installing Python applications
Tags: python, virtualenv, venv
Authors: Pedro F. Hernandez
Modified: 2019-02-09 12:00
Summary: Python scripts can be executed directly from their venv/virtualenv
         without activating the virtual environment. This patern leverages that
         to eliminate dependency conflicts and simplify maintanability.

I use to install python tools at the system level by way of:

```bash
sudo pip install awscli
```

After a short while, at the user level with:

```bash
pip install --user awscli
```

This worked great for some time, but as I installed more Python tools, I
started running into dependency conflicts. In the case of `awscli`, one or more
of its dependencies would end up conflicting with those of some other tools.

Now I just keep each tool in its own Python virtual environment.

For those not familiar with Python virtual environments I highly recommend
taking a look at one of the tutorials listed at the end of this post, then come
back to this one. Every Python developer should use Python virtual environments
day in and day out.

### The simple pattern

Let's say you want to install [JMESPath Terminal][JMESPATH_TERM], a great tool
by the way, and keep everything under `~/.local/`. I like to use `~/.local/`
as my own personal `/usr/local/`, you can replace it with whatever you like.

```bash
mkdir -p ~/.local/opt/python ~/.local/bin
python3 -m venv ~/.local/opt/python/jmespath-terminal
~/.local/opt/python/jmespath-terminal/bin/pip install -U pip
~/.local/opt/python/jmespath-terminal/bin/pip install jmespath-terminal
~/.local/opt/python/jmespath-terminal/bin/jpterm --help
```

Note that I called all the scripts using their fill path. This allows me to
avoid activating the Python virtual environment.

Now that everything is installed, let us make it accessible from our path.

```bash
cd ~/.local/bin
ln -s ../opt/python/jmespath-terminal/bin/jpterm .
export PATH=~/.local/bin:$PATH
```

Of course you will want to add the `export` to your shell configuration file.
After we add `~/.local/bin/` to the path we can execute `jpterm` from anywhere.

```bash
cd ~
which jpterm
jpterm --help
```

Done deal.  [JMESPath Terminal][JMESPATH_TERM] is now installed in its own
Python virtual environment with all of its dependencies completely isolated
from any other Python tools and libraries you might have installed.

This pattern can be applied to install many different Python based tools in
individual virtual environments.  We keep our path list concise by creating a
symlink out of `~/.local/bin/`, or whatever `bin` directory you have on your
path.

[azure-cli][AZ_CLI] is the only tool I have come across where this does not
work.  The issue is documented in [Azure/azure-cli#3989][AZ_BUG]


### Background

For a little background, the [Python venv documentation][VENV_QUOTE] states:

> You don’t specifically need to activate an environment; activation just
> prepends the virtual environment’s binary directory to your path, so that
> “python” invokes the virtual environment’s Python interpreter and you can run
> installed scripts without having to use their full path. However, all scripts
> installed in a virtual environment should be runnable without activating it,
> and run with the virtual environment’s Python automatically.

That pretty much sums it all up.


### Further reading

Python virtual environment tutorials:

- [Python Virtual Environments: A Primer][PRIMER]
- [Python Packaging User Guide][PPUG]

The tools:

- [venv][VENV] - How to create Python virtual environments since Python 3.3.
- [Virtualenv][VIRTUALENV] - For anything before Python 3.3.

The extreme details:

- [PEP 405 -- Python Virtual Environments][PEP405]
- [PEP 405 Specification][PEP405_SPEC] - The gritty details on how Python
  handles virtual environments.



[PRIMER]: https://realpython.com/python-virtual-environments-a-primer/
[PPUG]: https://packaging.python.org/guides/installing-using-pip-and-virtualenv/
[JMESPATH_TERM]: https://github.com/jmespath/jmespath.terminal
[PEP405]: https://www.python.org/dev/peps/pep-0405/
[PEP405_SPEC]: https://www.python.org/dev/peps/pep-0405/#specification
[VIRTUALENV]: https://virtualenv.pypa.io/en/latest/
[VENV]: https://docs.python.org/3/library/venv.html
[VENV_QUOTE]: https://docs.python.org/3/library/venv.html#creating-virtual-environments
[AZ_CLI]: https://pypi.org/project/azure-cli/
[AZ_BUG]: https://github.com/Azure/azure-cli/issues/3989
