# README

Zen is a modular CMS written on top of the awesome Ramaze framework. Zen was
built out of the frustration with Expression Engine, a popular CMS built on top
of the Codeigniter framework which in turn is written using PHP. While I really
like Codeigniter, ExpressionEngine and EllisLab there were several problems that
bothered me. So I set out to write a system that's loosely based on
ExpressionEngine but fits my needs. Because of this certain features may seem
similar to those provided by EE and while at certain points there are
similarities there are also pretty big differences.

## Documentation

* {file:introduction Introduction}
* {file:installation Installation}
* {file:changelog Changelog}
* {Categories Categories}
  * {Categories::Controller::CategoryGroups Managing Category Groups}
  * {Categories::Controller::Categories Managing Categories}
* {Comments Comments}
  * {Comments::Controller::Comments Managing Comments}
  * {Comments::Controller::CommentsForm Submitting Comments}
* {CustomFields Custom Fields}
  * {CustomFields::Controller::CustomFieldGroups Managing Groups}
  * {CustomFields::Controller::CustomFields Managing Fields}
  * {CustomFields::Controller::CustomFieldTypes Managing Types}
  * {CustomFields::BlueFormParameters Generating BlueForm Parameters}
* {Menus Menus}
  * {Menus::Controller::Menus Menu Management}
  * {Menus::Controller::MenuItems Managing Menu Items}
* {Sections Sections & Section Entries}
  * {Sections::Controller::Sections Managing Sections}
  * {Sections::Controller::SectionEntries Managing Section Entries}
* {Settings}
* {Users Users, User Groups and Permissions}
  * {Users::Controller::Users Managing Users}
  * {Users::Controller::UserGroups Managing User Groups}

## Hacking/Contributing

Zen follows a relatively strict set of guidelines when it comes to developing
core features and making sure everything goes along smoothly. When working with
Git a branch model based on [nvie's branch model][nvie branch model] is used.
This means that the "master" branch is directly used for pushing Gems and thus
should *always* contain stable code. Develop is used to contain less stable (but
not unstable) commits that will be pushed into "master" from time to time.  All
other branches, e.g. "rspec2" will be used for individual features.

Besides following this model developers are also expected to write tests using
either RSpec or Capybara for their features. Capybara is used to test
controllers and browser based actions while RSpec is used to test libraries,
helpers, etc.

## Coding Standards

* 2 spaces per indentation level for Ruby code.
* 4 spaces per indentation level for Javascript, CSS and HTML.
* Document your code, that includes CSS and Javascript files.
* No tabs at all times.
* Markdown is used for all markup.
* The maximum width of each line should be no more than 80 characters, this
  makes it easier to read code in terminals or when using split view modes.

## Community

* [Website][zen website]
* [Mailing list][mailing list]

Zen does not have it's own IRC channel at this time but you can usually find me
in any of the following channels on Freenode:

* \#forrst-chat
* \#ramaze
* \#ruby-lang

## License

Zen is licensed under the MIT license. For more information about this license
open the file "LICENSE".

[zen website]: http://zen-cms.com/
[zen documentation]: http://zen-cms.com/userguide/index.html
[nvie branch model]: http://nvie.com/posts/a-successful-git-branching-model/
[mailing list]: https://groups.google.com/forum/#!forum/zen-cms
