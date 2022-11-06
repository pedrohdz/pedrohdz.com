.. image:: https://github.com/pedrohdz/pedrohdz.com/actions/workflows/build.yaml/badge.svg
    :target: https://github.com/pedrohdz/pedrohdz.com/actions/workflows/build.yaml

.. image:: https://github.com/pedrohdz/pedrohdz.com/actions/workflows/deploy.yaml/badge.svg
    :target: https://github.com/pedrohdz/pedrohdz.com/actions/workflows/deploy.yaml


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

  make pelican-live-preview

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

- Move to GitHub Actions.
- Update/configure Dependabot.
- Add Super-linter.
- Add GitHub edit links.
- Update bootswatch.
- Streamline git sub-modules.
- Figure out what to do with analytics.
- Add search?


^^^^^^^^^^^^^^^
Further reading
^^^^^^^^^^^^^^^

- *TODO*

