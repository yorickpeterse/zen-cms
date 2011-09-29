# Introduction

Zen is a CMS that's built using Ramaze and aims to be an extremely flexible
system for managing web based applications. Before you continue reading this
guide it's important to know that Zen does things a bit different than other
systems. This may be confusing in the beginning and does make it a bit harder to
use but in the end it gives you a lot of power so it's worth the effort.

Zen was written after I got fed up with existing systems such as Expression
Engine and the pretty crippled Wordpress. While EE is a pretty flexible system
it's backend was a pain to use and I found it hugely annoying that a lot of
presentation related data was stored in the database. On top of that the
database itself was a big mess. Because I don't like using software that in my
opinion is broken I decided to roll my own system just like most other
programmers do.

A few of the possibilities offered by Zen are:

* Full control over the presentation, you get to decide what markup to use and
  how to display it.
* Full control of your content: you can define your own fields rather than being
  forced to use a pre defined set of fields.
* Fine control of user access.
* The power of Ramaze. Drop in existing applications, override layouts, it's all
  possible.
* Easy to change the layout of the backend or add new features using CSS and
  Javascript.

## Requirements

* Ruby 1.9.2 (MRI) (JRuby and Rubinius support is something I'm working on).
* Ramaze 2011.01.30 or newer, earlier versions will most likely cause problems.
* Any SQL database supported by Sequel. Zen has been tested and confirmed to
  work on MySQL, SQLite3 and PostgreSQL.
* A Rack compatible server such as Thin, Unicorn or Mongrel.

Depending on your own setup the following may be required as well:

* A library to convert your markup of choice to HTML. Zen by default has support
  for Textile using Redcloth and Markdown using RDiscount. However, These gems
  have to be installed manually.Depending on your database you may need to
  install additional gems.  If you're using MySQL it's recommended to use the
  mysql2 gem instead of the mysql one.

## Websites Using Zen

* http://yorickpeterse.com/
* http://ramaze.net/
* http://zen-cms.com/

## Special Thanks

Zen wasn't made by locking myself up in a basement for 6 months, while
developing the system I had a lot of help from various people and I'd like to
thank them for that. In particular I'd like to thank the following people:

* Michael Fellinger (manveru, creator of Ramaze/Innate) for his help and for
  creating such a wonderful framework.
* Yukihiro Matsumoto for creating Ruby.
* \#ramaze on Freenode, lots of people in there helped me getting started with
  Ramaze when I first started working with it around september 2010.
* EllisLab for creating ExpressionEngine, the system Zen was inspired by.
