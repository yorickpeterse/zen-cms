# Zen

Zen is a flexible Content Management System that gives you full control over
your content and presentation without limiting your possibilities. One of the
key features of Zen is that you're able to define your own content types and
fields. No longer are you limited to only filling in a title and a body field,
instead you can just create your own as you see fit. Another interesting feature
is that Zen allows you to "embed" Ramaze applications inside Zen (although they
might need some minor changes).

Zen was originally inspired by [Expression Engine][ee]. EE is based on a similar
idea of allowing you to define your own fields and such. As much as I enjoyed
using EE at the time there were several very annoying limitations/problems. The
admin interface was a mess, the interal API wasn't very well organized and the
database design was even worse (for example, settings are serialized and encoded
using some algorithm). This started off the idea of Zen: something that's based
on a similar idea but solves all the problems I was having with Expression
Engine.

When building Zen I tried to make it pleasant to use, whether you're a
developer, designer or just a user. I tried to make the administration interface
as easy to use (although it has it's quirks) as well as making the internal API
a breeze to use. Another important part is performance. If I'm going to use a
content management system it should be fast and shouldn't use excessive amounts
of RAM. It's hard to say how fast Zen really is as it depends on your
configuration and hardware but one thing is sure: out of the box it should be
able to handle lots of requests per second without any trouble.

Some of the core features of Zen are listed below. Note that these are only a
small portion of what it can do.

* Define your own content fields (called "custom fields") with their own type,
  markup, rules and so on.
* Fine grained control over user access thanks to an easy to use permission
  system.
* Be able to use everything Ramaze has to offer. Want to use your own admin
  layout? No problem! Want to drop in an existing Ramaze application? Sure!
* A well documented, tested and easy to understand API.
* A database structure that doesn't make you cry.

## Chapters

* {file:installation Installation}
* {file:getting_started Getting Started}
* {file:hacking Hacking/Contributing}
* {file:changelog Changelog}
* {Dashboard::Controller::Dashboard Dashboard}
* {Categories Categories}
  * {Categories::Controller::CategoryGroups Managing Category Groups}
  * {Categories::Controller::Categories Managing Categories}
  * {Ramaze::Helper::CategoryFrontend#get_categories Categories & Templates}
* {Comments Comments}
  * {Comments::Controller::Comments Managing Comments}
  * {Comments::Controller::CommentsForm Submitting Comments}
  * {Comments::AntiSpam Validating Comments For Spam}
  * {Ramaze::Helper::CommentFrontend#get_comments Comments & Templates}
* {CustomFields Custom Fields}
  * {CustomFields::Controller::CustomFieldGroups Managing Groups}
  * {CustomFields::Controller::CustomFields Managing Fields}
  * {CustomFields::Controller::CustomFieldTypes Managing Types}
  * {CustomFields::BlueFormParameters Generating BlueForm Parameters}
* {Menus Menus}
  * {Menus::Controller::Menus Menu Management}
  * {Menus::Controller::MenuItems Managing Menu Items}
  * {Ramaze::Helper::MenuFrontend#render_menu Menus & Templates}
* {Sections Sections & Section Entries}
  * {Sections::Controller::Sections Managing Sections}
  * {Sections::Controller::SectionEntries Managing Section Entries}
  * {Ramaze::Helper::SectionFrontend#get_entries Section Entries & Templates}
* {Settings}
  * {Settings::Controller::Settings Managing Settings}
  * {Settings::SingletonMethods#get_setting Retrieving Settings}
* {Users Users, User Groups and Permissions}
  * {Users::Controller::Users Managing Users}
  * {Users::Controller::UserGroups Managing User Groups}
* {Zen::Package Packages}
* {Zen::Theme Themes}
* {Zen::Language Localization}
* {Zen::Event Events}
* {Zen::Validation Validating Objects}
* {file:asset_management Asset Management}
* {file:javascript Javascript API}

## Requirements

* Ruby >= 1.9.2 (Rubinius, jruby and others are not supported).
* Ramaze 2011.10.23 or newer.
* A SQL database supported by Sequel. Zen has been tested and confirmed to
  work on MySQL, SQLite3 and PostgreSQL. You'll also need the required gems for
  these DBMS' such as "mysql2" for MySQL and "pg" for PostgreSQL.
* A Rack compatible server such as Thin or Unicorn.
* A library to convert your markup of choice to HTML. Zen by default has support
  for Textile using Redcloth and Markdown using RDiscount. RDiscount and
  RedCloth are installed automatically when needed.

## Community

* [Website][zen website]
* [Mailing list][mailing list]

Zen does not have it's own IRC channel at this time but you can usually find me
in any of the following channels on Freenode:

* \#forrst-chat
* \#ramaze
* \#ruby-lang

## Websites Using Zen

* http://yorickpeterse.com/
* http://ramaze.net/
* http://zen-cms.com/
* http://aplusm.me/

If you've built a website using Zen and you'd like to have it listed here sent
an Email to me (yorickpeterse [at] gmail [dot] com) or send an Email to the
mailing list.

## Special Thanks

While developing Zen I had a lot of help from various people and I'd like to
thank them for that. In particular I'd like to thank the following people:

* Michael Fellinger (manveru, creator of Ramaze/Innate) for his help and for
  creating such a wonderful framework.
* Yukihiro Matsumoto for creating Ruby.
* \#ramaze on Freenode, lots of people in there helped me getting started with
  Ramaze when I first started working with it around september 2010.
* EllisLab for creating ExpressionEngine, the system Zen was inspired by.
* Loren Segal for creating YARD and helping me out with various issues.

## License

Zen is licensed under the MIT license. For more information about this license
open the file "LICENSE".

[zen website]: http://zen-cms.com/
[zen documentation]: http://zen-cms.com/userguide/index.html
[mailing list]: https://groups.google.com/forum/#!forum/zen-cms
[ee]: http://expressionengine.com/
