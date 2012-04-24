# @title Installation
# Installation

Zen can be installed in two different ways, either by using Rubygems or Git. The
former is the easiest of the two as it only requires a single command. The
latter is more useful if you want to hack on Zen while using it.

## Rubygems Installation

Installing Zen using Rubygems can be done by running the following command in
your terminal:

    $ gem install zen

If you want to install a specific version of Zen you can provide the `-v`
option:

    $ gem install zen -v [VERSION]

For example, if you want to install 0.2.8 you'd run the following command:

    $ gem install zen -v 0.2.8

## Git Installation

When you want to submit a patch, hack the core or are just interested in
browsing the code you'll want to install a copy of the Git repository. This can
be done by a simply cloning the repository:

    $ git clone git://github.com/zen-cms/Zen-Core.git zen_core

This command saves a local copy of Zen in the directory `./zen_core`. Now that
you have a local copy there are two ways of using it:

1. Manually build the Gem each time you've made a change.
2. Directly load the Zen installation from your application.

The latter is recommended as you don't have to build the Gem each time. In order
to do this you simply need to replace all calls to require() that load data from
the gem with a path to the local copy of Zen. This means that the following:

    require 'zen'

Should be converted to this:

    require File.expand_path('../path/to/zen/lib/zen', __FILE__)

For an overview of all available tasks that can be executed in your local copy
of Zen execute the following command:

    $ rake -T
