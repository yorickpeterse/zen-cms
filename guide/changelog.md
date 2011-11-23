# Changelog

## Git Head

* Started using checkboxes in favor of select boxes as they're easier to use.
* Fixed a small issue that would make it impossible to add/update categories of
  a section entry.
* Core packages no longer include certain modules just to so that they don't
  have to specify the full namespace to a class.
* Added an event system (Zen::Event) and a bucket load of events.
* Merged Zen.init and Zen.post_init into Zen.start.
* Fixed various YARD formatting issues.
* Localized all of the Javascript.
* All specs now pass on Ruby 1.9.3.
* Made it easier to format dates and do other locale based actions using
  Ramaze::Helper::Locale.
* Dropped Zen::Asset in favor of Ramaze::Asset.
* Updated Mootools Core and Mootools More to version 1.4.
* Fixed an issue related to creating users without passwords.
* New API for Zen::Package.
* ACL system has been re-written from scratch.
* Merged Zen::Theme::Base with Zen::Theme and Zen::Plugin::Base with
  Zen::Plugin.
* Sections are no longer directly related to template groups.
* Added a package that displays the installed languages, packages and themes.
* New API for Zen::Language.
* Removed Zen::Plugin.
* Improved settings API.
* Visitors can now register an account (or not) based on a setting.
* Vendorized Ramaze::Helper::StackedAspect from Ramaze Git.
* Added a helper for allowing users to access admin URLs.
* User statuses are now stored as IDs instead of plain text.
* Full support for PostgreSQL.
* Zen now requires Ramaze >= 2011.10.23.
* Content in the admin panel can now be searched using regular expressions (not
  supported in SQLite3) or LIKE statements (used in case of SQLite3).
* New documentation based on YARD instead of Sphinx.
* Vendorized the Sequel sluggable plugin.
* Fixed an issue that would cause comments to be displayed regardless of their
  status.
* Lots of small fixes, improvements, etc.

## 0.2.8 - August 3, 2011

* Replaced RSpec with Bacon.
* When retrieving section entries comments are now retrieved properly.
* Comments and categories are no longer retrieved by default when calling the
  section entries plugin.
* Statuses of comments and section entries are now stored in a separate table.
* Plugins can be called as a singleton using Zen::Plugin.plugin.
* The column menu_items.order has been renamed to menu_items.sort_order.
* The accessor method for settings that defines the possible values now accepts
  a Proc, this makes it possible for conditional possible values and such.
* Various performance tweaks.
* The rake task proto:package has been removed.
* The core package have been cleaned up and are much more robust thanks to
  better validation of various objects such as category groups when viewing a
  list of categories.
* Assets can now be loaded for specific methods using Zen::Asset by specifying
  the :method key.
* Users can now create their own custom field types.
* Overview pages now paginate their results so they display a maximum of 20 rows
  per page.
* All references to "css_class" and "css_id" have been replaced with
  "html_class" and "html_id".
* Ramaze::Helper::Common has been removed.
* Tables can now be sorted by clicking on the headers.
* The required permissions for the #save() methods of all controllers have been
  set correctly (issue #28).
* The executable now uses OptionParser instead of Commander.
* The total code coverage has been increased to 95.63% meaning Zen has become
  even more stable than ever.
* Fixed a few broken migrations.

## 0.2.7 - June 16, 2011

* Started using Ramaze.setup for Gem management.
* Websites can no longer be marked as "offline", this was a rather useless
  feature anyway.
* Fixed various bugs

## 0.2.6.1 - June 1, 2011

* Dropped Zen.settings and modified the settings plugin so that it works
  properly when using a multi-process based environment such as Unicorn.

## 0.2.6 - May 29, 2011

* Zen is now using RVM for gem management and such.
* Began working on making Zen compatible with at least JRuby. Rubinius isn't
  worth the effort at this time.
* Removed Ramaze::Helper::Common.notification in favor of
  Ramaze::Helper::Message.
* Dropped Zen::Database, Zen::Settings and most of the options in favor of
  instance variables set in the main Zen module. See commit
  d40ee1c2e518a323b2983e1bcfb7a0d863bf3b2f for more information.
* Translated Zen to Dutch.
* Re-organized the application prototypes to make them easier to use/understand.
* Implemented the anti-spam system as a plugin and added a decent XSS protection
  system using Loofah.
* Various changes to the Javascript classes.
