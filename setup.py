#!/usr/bin/env python
from setuptools import setup

_VERSION = '0.0.0'


def long_description():
    with open('README.rst', 'rb') as handle:
        return handle.read().decode('utf-8')


setup(
    name='pedrohdz-com',
    version=_VERSION,
    author='Pedro H.',
    author_email='pedro.codez@gmail.com',
    description='Pelican configuration and site for pedrohdz.com',
    long_description=long_description(),
    url='https://github.com/pedrohdz/pedrohdz.com',
    classifiers=[
        'Development Status :: 3 - Alpha',
        'Programming Language :: Python :: 3.6',
    ],
    keywords='pelican',
    install_requires=[
        'pelican',
        'Markdown>=2.6.11',
        # `beautifulsoup4` is required by `ext/pelican-plugins/bootstrapify`
        'beautifulsoup4>=4.6.0'
        'pymdown-extensions>=4.9.2',
    ],
    dependency_links=[
        'git+https://github.com/pedrohdz/pelican.git#egg=pelican',
    ],
)
