## 0.2.7.1 - July XXX, 2011

* Replaced RSpec with Bacon.
* When retrieving section entries comments are now retrieved properly.
* Comments and categories are no longer retrieved by default when calling the
  section entries plugin.
* Statuses of comments and section entries are now stored in a separate table.
* Plugins can be called as a singleton using Zen::Plugin.plugin.
* The column menu\_items.order has been renamed to menu\_items.sort\_order.
* The accessor method for settings that defines the possible values now accepts
  a Proc, this makes it possible for conditional possible values and such.
* Various performance tweaks.
* The rake task proto:package has been removed.
* The core package have been cleaned up and are much more robust thanks to
  better validation of various objects such as category groups when viewing a
  list of categories.
* Assets can now be loaded for specific methods using Zen::Asset by specifying
  the :method key.

## 0.2.7 - June 16th, 2011

* Started using Ramaze.setup for Gem management.
* Websites can no longer be marked as "offline", this was a rather useless 
  feature anyway.
* Fixed various bugs

## 0.2.6.1 - June 1st, 2011

* Dropped Zen.settings and modified the settings plugin so that it works 
  properly when using a multi-process based environment such as Unicorn.

## 0.2.6 - May 29th, 2011

* Zen is now using RVM for gem management and such.
* Began working on making Zen compatible with at least JRuby. Rubinius isn't 
  worth the effort at this time.
* Removed Ramaze::Helper::Common.notification in favor of Ramaze::Helper::Message.
* Dropped Zen::Database, Zen::Settings and most of the options in favor of 
  instance variables set in the main Zen module. See commit 
  [d40ee1c2e518a323b2983e1bcfb7a0d863bf3b2f][d40ee1c2e518a323b2983e1bcfb7a0d863bf3b2f] 
  for more information.
* Translated Zen to Dutch.
* Re-organized the application prototypes to make them easier to use/understand.
* Implemented the anti-spam system as a plugin and added a decent XSS protection 
  system using Loofah.
* Various changes to the Javascript classes.

[d40ee1c2e518a323b2983e1bcfb7a0d863bf3b2f]: https://github.com/zen-cms/Zen-Core/commit/d40ee1c2e518a323b2983e1bcfb7a0d863bf3b2f
