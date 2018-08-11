#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals
from os import path

AUTHOR = 'Pedro Hernandez'
SITENAME = 'pedrohdz.com'
SITEURL = ''
TIMEZONE = 'UTC'
DEFAULT_LANG = 'en'

theme_name = 'pelican-bootstrap3'
theme_override = path.join('theme-overrides', theme_name)


# -----------------------------------------------------------------------------
# Paths/files
# -----------------------------------------------------------------------------
# Keeping paths plural.  This explains it best:
#     - http://stackoverflow.com/a/21809963/2721824
PATH = 'content'
IGNORE_FILES = ('.#*', '.*.swp', '*~')

# Including `plugins/bootstrap-rst` is a shitty hack to resove Python path
# issues.
PLUGIN_PATHS = (
    path.join('ext', 'pelican-plugins'),
    path.join('ext', 'pelican-plugins', 'bootstrap-rst'))

# Blog/articles
ARTICLE_PATHS = ('posts',)
ARTICLE_URL = 'posts/{category}/{slug}/'
ARTICLE_SAVE_AS = 'posts/{category}/{slug}/index.html'

# Draft blog/articles
WITH_FUTURE_DATES = True
DRAFT_URL = 'posts/drafts/{category}/{slug}/'
DRAFT_SAVE_AS = 'posts/drafts/{category}/{slug}/index.html'

# Pages
PAGES_PATH = ('pages',)
PAGE_URL = 'pages/{slug}/'
PAGE_SAVE_AS = 'pages/{slug}/index.html'

USE_FOLDER_AS_CATEGORY = False
SLUGIFY_SOURCE = 'basename'
PATH_METADATA = ('posts/(?P<category>[^/]+)'
                 '/(?P<date>\d{4}-\d{2}-\d{2})_(?P<slug>[^/]+)/')

THEME = path.join('ext', 'pelican-themes', theme_name)
THEME_TEMPLATES_OVERRIDES = (
    'templates',
    path.join(theme_override, 'templates'))

STATIC_PATHS = (
    'css',
    'images',
    'js',
    'posts',
    path.join(theme_override, 'static'))


# -----------------------------------------------------------------------------
# Other
# -----------------------------------------------------------------------------
PLUGINS = ('series',
           'tag_cloud',
           'i18n_subsites',
           'bootstrapify',
           'bootstrap-rst',
           'plantuml')
JINJA_ENVIRONMENT = {'extensions': ('jinja2.ext.i18n', 'jinja2.ext.do')}

# For lists of MarkDown extentions:
#    - http://pythonhosted.org/Markdown/extensions/index.html
#    - http://facelessuser.github.io/pymdown-extensions/
#    - https://github.com/waylan/Python-Markdown/wiki/Third-Party-Extensions
MARKDOWN = {
    'extension_configs': {
        'markdown.extensions.codehilite': {'css_class': 'highlight'},
        # START - pymdownx.extra
        # Explicitly including individual pymdownx.extra sub-parts to
        # allow for configuration.
        'pymdownx.betterem': {},
        'pymdownx.superfences': {'disable_indented_code_blocks': True},
        'markdown.extensions.footnotes': {},
        'markdown.extensions.attr_list': {},
        'markdown.extensions.def_list': {},
        'markdown.extensions.tables': {},
        'markdown.extensions.abbr': {},
        'pymdownx.extrarawhtml': {},
        # END - pymdownx.extra
        'markdown.extensions.meta': {},
        'markdown.extensions.toc': {'anchorlink': True},
        'pymdownx.inlinehilite': {}
    }
}


# Feed generation is usually not desired when developing
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
AUTHOR_FEED_ATOM = None
AUTHOR_FEED_RSS = None

# Social widget
SOCIAL = (('twitter', 'https://twitter.com/pedrohdz128'),
          ('linkedin', 'https://www.linkedin.com/in/pedrohdz'),
          ('github', 'https://github.com/pedrohdz'),
          ('stack-overflow', 'http://stackoverflow.com/users/2721824/pedrohdz'))  # noqa

PYGMENTS_STYLE = 'tango'
# PYGMENTS_STYLE = 'paraiso-light'
# PYGMENTS_STYLE = 'perldoc'
# PYGMENTS_STYLE = 'friendly'
# PYGMENTS_STYLE = 'manni'
# PYGMENTS_STYLE = 'solarizeddark'
# PYGMENTS_STYLE = 'solarizedlight'
# PYGMENTS_STYLE = 'zenburn'

DEFAULT_PAGINATION = 20
DISPLAY_PAGES_ON_MENU = True
DISPLAY_CATEGORIES_ON_MENU = False

# There's a bug where this is randomly applied, causing issues on pages randmly
# being made drafts.
# DEFAULT_METADATA = {'Status': 'draft'}

TEMPLATE_PAGES = {
    # 'template_pages/contact.html': 'pages/contact/index.html',
    'template_pages/about.html': 'pages/about/index.html',
    'template_pages/privacy.html': 'pages/privacy/index.html',
    'template_pages/google37d6d99e76a0b857.html': 'google37d6d99e76a0b857.html'
}

MENUITEMS = (
    ('Archive', '/archives.html'),
    ('Categories', '/categories.html'),
    ('Tags', '/tags.html'),
    # ('Contact', '/pages/contact/'),
    ('About', '/pages/about/')
)


# -----------------------------------------------------------------------------
# Theme configuration (pelican-bootstrap3)
# -----------------------------------------------------------------------------
BOOTSTRAP_THEME = 'drounin'
# BOOTSTRAP_THEME = 'yeti'
# BOOTSTRAP_THEME = 'simplex'
# BOOTSTRAP_THEME = 'superhero'

CUSTOM_CSS = 'css/custom.css'

# SITELOGO = 'images/digital_rounin_menu_logo.png'

DISPLAY_TAGS_INLINE = True
DISPLAY_BREADCRUMBS = True
DISPLAY_CATEGORY_IN_BREADCRUMBS = True

PADDED_SINGLE_COLUMN_STYLE = True

BANNER = 'images/city-scape-fog-background-small.jpg'
BANNER_ALL_PAGES = True
BANNER_SUBTITLE = 'Pedro\'s blog'

# ----
# TESTING SIDEBAR
# ----
# HIDE_SIDEBAR = True
# SIDEBAR_ON_LEFT = True
# DISABLE_SIDEBAR_TITLE_ICONS = True
# DISPLAY_RECENT_POSTS_ON_SIDEBAR = True
# DISPLAY_CATEGORIES_ON_SIDEBAR = True
# DISPLAY_TAGS_ON_SIDEBAR = True

# DISPLAY_SERIES_ON_SIDEBAR = True
# GITHUB_USER = 'pedrohdz'
# GITHUB_SHOW_USER_LINK = True
# TWITTER_USERNAME = 'pedrohdz128'
# TWITTER_WIDGET_ID = True
# SIDEBAR_IMAGES = ('http://upload.wikimedia.org/wikipedia/commons/d/d9/Test.png',)  # noqa
# SIDEBAR_IMAGES_HEADER = "Images"
# LINKS = (('Pelican', 'http://getpelican.com/'),
#          ('Python.org', 'http://python.org/'),
#          ('Jinja2', 'http://jinja.pocoo.org/'))

# Uncomment following line if you want document-relative URLs when developing
# RELATIVE_URLS = True
