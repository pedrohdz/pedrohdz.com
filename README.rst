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

  git clone git@github.com:pedrohdz/pedrohdz.com.git
  cd pedrohdz.com
  git submodule update --init
  make


Local testing
~~~~~~~~~~~~~

In one terminal execute:

.. code:: sh

  make pelican-server

Point your browser at `http://localhost:8000/ <http://localhost:8000/>`_.


Deploy
~~~~~~

.. code:: sh

  make bumpversion-*
  git push && git push --tags

Check `Travis-CI <https://travis-ci.org/pedrohdz/pedrohdz.com>`_. and wait for
the build to finish. It should auto deploy on new version tags.

Then check `pedrohdz.com <https://pedrohdz.com/>`_.


Clean up
~~~~~~~~

.. code:: sh

  make clean


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

