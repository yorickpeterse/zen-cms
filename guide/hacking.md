# @title Hacking & Contributing
# Hacking & Contributing

Everybody is free to contribute to Zen. However, to ensure that the quality of
Zen doesn't degrade developers should stick with the guidelines described in
this document. Zen also follows the [Ramaze guidelines][ramaze guidelines] as
much as possible.

## Coding Standards

Zen follows a rather strict set of coding guidelines that developers should
follow if they wish to contribute to Zen. Write your code like the next
developer looking at it is a psychopath with an axe and knows where you live.

### Indentation

For Ruby 2 spaces per indentation level is used. The use of tabs is not
allowed at all times and pull requests containing incorrectly indented code will
not be accepted until the indentation has been fixed.

For Javascript, CSS and HTML 4 spaces per indentation level is used instead of
2 spaces. This is because I personally find 4 spaces to be far easier to read in
these languages. Again no tabs are allowed.

### Documentation

The same rule about the psychopath with the axe applies to documentation. Proper
documentation is very, *very* important. Documentation should be written
following the YARD syntax and by using Markdown where needed. If you need any
examples just look at the source code of {Zen::Package} or {Zen::Theme}.

### Line Width

The maximum amount of characters per line should be no greater than 80
characters whenever possible. Sometimes it's simply not possible (e.g. when
adding a URL) but try to stick to this as much as possible.

Limiting the amount of characters per line to 80 ensures that everybody will be
able to read it, whether they're using Vim with multiple split windows or
reading a file in their terminal.

### CSS

When writing CSS the properties of a selector (background-image, color, etc)
should be sorted alphabetically. There are a few exceptions to this. For
example, the CSS file buttons.css contains a set of background-image properties
that are grouped together for better readability. As long as it's readable I'm
ok with it.

## Comitting

Besides the guidelines set in [Ramaze's comit messages][commit guidelines]
section Zen comes with the requirement that all commits are signed off using
``git commit --sign``. For more information about signing commits (and why
it is a good idea) see the following pages:

* <http://kerneltrap.org/files/Jeremy/DCO.txt>
* <http://stackoverflow.com/questions/1962094/what-is-the-sign-off-feature-in-git-for>

## Branching

Zen has two main branches, "master" and "develop". The master branch is directly
tied to releases, this means that it should **always** contain stable and fully
tested code. In almost all cases I (Yorick) will be the only one merging
changes into this branch. The develop branch is used as a place to merge other
branches into as well as for comitting small changes such as typos, small bug
fixes and so on.

Big features such as a new backend design should go in a separate branch with an
easy to remember and meaningful name. In this example the branch name could be
"new\_design" or simply "design".

## Tests

Tests for Zen are written using [Bacon][bacon]. New features, modified ones, it
doesn't matter, they should all be tested. Currently Zen's code coverage
(measured using SimpleCov) sits around 96% and I intent to keep it above 95%.
The test ouput is displayed using [TAP][tap protocol].

[ramaze guidelines]: http://ramaze.net/documentation/file.contributing.html
[commit guidelines]: http://ramaze.net/documentation/file.contributing.html#Commit_Messages
[bacon]: https://github.com/chneukirchen/bacon
[tap protocol]: https://en.wikipedia.org/wiki/Test_Anything_Protocol
[allman style]: https://en.wikipedia.org/wiki/Indent_style#Allman_style
