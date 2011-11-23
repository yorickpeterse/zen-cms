# Hacking & Contributing

Everybody is free to contribute to Zen. However, to ensure that the quality of
Zen doesn't degrade developers should stick with the guidelines described in
this document. Zen also follows the [Ramaze guidelines][ramaze guidelines] as
much as possible.

## General Standards

* 2 spaces per indentation level for Ruby code.
* 4 spaces per indentation level for Javascript, CSS and HTML.
* Document your code, that includes CSS (when dealing with complex selectors)
  and Javascript files.
* No tabs at all times.
* Markdown is used for all markup.
* The maximum width of each line should be no more than 80 characters, this
  makes it easier to read code in terminals or when using split view modes.

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
