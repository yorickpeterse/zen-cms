# README

Zen is a modular CMS written on top of the awesome Ramaze framework.
Zen was built out of the frustration with Expression Engine, a popular CMS built on top of
the Codeigniter framework which in turn is written using PHP. While I really like 
Codeigniter, ExpressionEngine and EllisLab there were several problems that bothered me.
So I set out to write a system that's loosely based on ExpressionEngine but fits my needs.
Because of this certain features may seem similar to those provided by EE and while at
certain points there are similarities there are also pretty big differences.

## Requirements

* Ramaze 2011.01.30 or newer 
* Ruby 1.9 or newer
* A Defensio API key (for the comments system)
* A database (MySQL, PostgreSQL, etc)
* A HDD with some space left, mostly for the log files

## Installation

Installing Zen using Rubygems is probably the easiest way:

    $ gem install zen
    $ zen app application_name

If you like to hack with the core of Zen it's best to install it using Git:

    $ git clone git://github.com/zen-cms/zen-core.git
    $ cd zen-core
    $ rake build:gem_clean

## Database Support

Technically Zen should run on any given DBMS that's supported by Sequel as Zen doesn't
use any DBMS specific field types. However, there might be a chance that it won't work.
If you happen to have any problems getting Zen running using your database of choice
feel free to submit a ticket or post it on the mailing list.

The Zen website itself is tested and served using MySQL, SQLite3 works just as fine and
PostgreSQL will be tested in the near future.

## Running Zen

Zen can be run using any webserver as long as it supports Rack. Thin, Unicorn or Passenger,
they should all work. The main website of Zen is served using Unicorn and Nginx, development
is done using WEBRick and Unicorn.

## Documentation

The documentation (both the userguide and the API docs) can be found on the website,
located [here][zen documentation].

## Hacking/Contributing

Zen follows a relatively strict set of guidelines when it comes to developing core features
and making sure everything goes along smoothly. When working with Git a branch model based
on [nvie's branch model][nvie branch model] is used. This means that the "master" branch
is directly used for pushing Gems and thus should *always* contain stable code. Develop
is used to contain less stable (but not unstable) commits that will be pushed into "master"
from time to time. All other branches, e.g. "rspec2" will be used for individual features.

Besides following this model developers are also expected to write tests using either
RSpec or Webrat for their features. Webrat is used to test controllers and browser based
tests while RSpec is used to test libraries, helpers, etc.

If you have a cool idea, implemented it and think it's worth merging into Zen itself feel
free to submit a pull request and I'll take a look at it.

## Coding Standards

* 2 spaces per indentation level for Ruby code.
* 4 spaces per indentation level for Javascript, CSS and HTML.
* Document your code, that includes CSS and Javascript files.
* No tabs at all times
* Markdown is used for all markup
* Comments should be in English 
* The maximum width of each line should be no more than 90 columns, this makes it easier
to read code in terminals or when using split view modes.

## Community

* [Website][zen website]
* Mailing list

Zen does not have it's own IRC channel at this time but you can usually find me in any
of the following channels on Freenode:

* \#forrst-chat
* \#ramaze
* \#codeigniter
* \#mootools

## License

Zen is licensed under the MIT license. For more information about this license open
the file "license.txt".

[zen website]: http://zen-cms.com/
[zen documentation]: http://zen-cms.com/userguide/
[nvie branch model]: http://nvie.com/posts/a-successful-git-branching-model/
