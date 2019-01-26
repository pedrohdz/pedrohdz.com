.. image:: https://travis-ci.org/pedrohdz/pedrohdz.com.svg?branch=master
    :target: https://travis-ci.org/pedrohdz/pedrohdz.com

===============================================================================
pedrohdz.com
===============================================================================

Source for `pedrohdz.com <https://pedrohdz.com/>`_.

-------------------------------------------------------------------------------
General tasks
-------------------------------------------------------------------------------

^^^^^^^
Pelican
^^^^^^^

Initial setup
~~~~~~~~~~~~~

.. code:: sh

  $ git clone git@github.com:pedrohdz/pedrohdz.com.git
  $ cd pedrohdz.com
  $ git submodule update --init --recursive
  $ python3.6 -m venv .virtualenv
  $ source .virtualenv/bin/activate
  $ pip install -r requirements.txt


Local testing
~~~~~~~~~~~~~

In one terminal execute:

.. code:: sh

  $ pelican --debug --autoreload

In a second terminal execute:

.. code:: sh

  $ cd output/
  $ python -m pelican.server


Point your browser at `http://localhost:8000/ <http://localhost:8000/>`_.


Deploy
~~~~~~

.. code:: sh

  $ pelican -d -s publishconf.py
  $ aws s3 sync --delete ./output/ s3://pedrohdz.com/

Check `pedrohdz.com <https://pedrohdz.com/>`_.


Clean up
~~~~~~~~

.. code:: sh

  $ rm -Rf .virtualenv/ __pycache__/ output/


-------------------------------------------------------------------------------
Apendix
-------------------------------------------------------------------------------

^^^^^^^^^^
Todo tasks
^^^^^^^^^^

- Streamline git sub-modules.


^^^^^^^^^^^^^^^
Further reading
^^^^^^^^^^^^^^^

- *TODO*

