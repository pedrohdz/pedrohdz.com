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
    author_email='5179251+pedrohdz@users.noreply.github.com',
    description='Pelican configuration and site for pedrohdz.com',
    long_description=long_description(),
    url='https://github.com/pedrohdz/pedrohdz.com',
    classifiers=[
        'Development Status :: 3 - Alpha',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
    ],
    keywords='pelican',
    install_requires=[
        'pelican>=4.0.1',
        'Markdown>=3.0.1',
        # `beautifulsoup4` is required by `ext/pelican-plugins/bootstrapify`
        'beautifulsoup4>=4.7.1',
        'pymdown-extensions>=6.0',
        'awscli>=1.16.92',
    ],
)
