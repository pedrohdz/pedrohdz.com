Title: Vim folding rules for YAML
Modified: 2017-05-31
Tags: vim, yaml, raml, saltstack, sls 
Authors: Pedro F. H.
Summary: More readable Vim folding rules for YAML, RAML and SaltStack SLS files.
Status: published

The default _Vim_ folding rules for _YAML_ files were always a bit of an eye
strain for me.  The folding commands do not behave as one would expect them to
as well.  More about all this in the _Explanation_ section below.

This got me to throw together a quick and simple _Vim_ plugin to handle _YAML_
folding more cleanly, [vim-yaml-folds][].  Here is what _YAML_ folding looks
like with [vim-yaml-folds][] installed:

![View of YAML folding with new folding rules]({attach}new_yaml_folding.png){: .center-block}

A fold contains the beginning of a _YAML_ section with everything underneath it
included.

If you know what I'm talking about and do not care for an explanation, feel
free to skip the _Explanation_ and install [vim-yaml-folds][] if you would
like.


## Explanation

Here is what it looks like _YAML_ folding looks like with the default _Vim_
configuration:

![View of Vim's default YAML folding rules]({attach}default_yaml_folding.png){: .center-block}

The most obvious issue is the format of the fold lines.  Take a look at the
following line:

![Line 11 of YAML folding example]({attach}line_11_yaml_folding.png){: .center-block}

Starting with the plus symbol (`+`) followed by a bunch of dashes (`-`) then
the number of lines just looks like noise.  Also, shouldn't it just be folded
up into the `test_self` section?  Same should apply to list of `rules`.

The default folding behaviour for _YAML_ files in _Vim_ is that the folding
level matches the indentation level of the line.  What ends up happening is
that the folding level begins on the line following the start of a _YAML_
block.  This default folding rules can lead to some unexpected behaviour.  Say
you move the cursor to the `test_self:` and try and fold everything under it
(`zc`).  What actually happens is that everything under `secgroups` gets
folded.

[vim-yaml-folds][] is an attempt at cleaning all this up.


## Further reading

- Guides to utilizing folds in _Vim_:
    - [How to fold Vimcast][]
    - [Vim folding cheatsheet][]
- How to implement folding rules in _Vim_:
    - [Writing a custom fold expression Vimcast][]
- [Vim fold documentation][]
- [vim-yaml-folds Vim Scripts listing][]

[vim-yaml-folds]: https://github.com/digitalrounin/vim-yaml-folds
[vim-yaml-folds Vim Scripts listing]: http://www.vim.org/scripts/script.php?script_id=5559
[How to fold Vimcast]: http://vimcasts.org/episodes/how-to-fold/
[Writing a custom fold expression Vimcast]: http://vimcasts.org/episodes/writing-a-custom-fold-expression/
[Vim folding cheatsheet]: https://gist.github.com/lestoni/8c74da455cce3d36eb68
[Vim fold documentation]: http://vimdoc.sourceforge.net/htmldoc/fold.html
