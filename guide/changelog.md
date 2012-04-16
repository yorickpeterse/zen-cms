# Changelog

## 0.4.2 - April 16th, 2012

* Bugfix for rendering menu items in the backend. Due to a typo the menu items
  in the backend would only be displayed if a user was a super user. Because
  this is a rather annoying issue I decided to push another release.

## 0.4.1 - April 16th, 2012

* Updated various version requirements.
* Menu items are sorted properly, in some cases the sort order would be broken
  due to the dataset being sorted after it was retrieved.
* Replaced RDiscount with Redcarpet.
* Show menu items without permissions.
* Documentation improvements and fixed various spelling errors.
* Removed the `post_start` event.
* Load core packages when connecting to a DB.
* Call `:post_start` before building assets.
* Hide messages by clicking on them.
* Basic set of styles for the pagination buttons.
* Preserve author IDs for section entries
* Handle forms using the Mootools class Zen.Form.
* Moved Mootools events into their own file.
* Set Ramaze.options.mode before Zen.root.

## 0.4 - March 7th, 2012

* Packages can contain multiple menus.
* New UI for the backend.
* All Javascript code is executed in strict mode.
* Added a new Javascript class for parsing hash fragments: Zen.Hash.
* Active tabs "persist" by changing URL hash fragments.
* Slugs are generated less aggressively, allowing the use of characters such as
  hyphens.
* Various documentation improvements and numerous bug fixes.
* Datepickers can be customized using HTML attributes.
* Etanni template tags are escaped when dealing with user input.
* Added a new package: "Dashboard". This package shows various widgets and
  replaces the "Sections" package as the landing page after logging in.
* Performance improvements for ``Ramaze::Helper::MenuFrontend#render_menu()``.
  These improvements mean that only two queries are needed to retrieve a menu
  and build the hierarchy of menu items (regardless of the amount).
* Fixed an issue that would incorrectly generate application names when creating
  a new application using ``zen create``.
* Full stack traces are logged in case of errors rather than just the message.
* Model related events (e.g. `before_new_section_entry`) have been moved into
  their corresponding models.
* Menu item manager has been re-written so that menu items can be organized
  using a drop and drag interface.
* The various assets used by Zen have been re-organized.
* Custom data can be stored in themes and packages in the ``env`` attribute.
* Forms are automatically saved every 10 minutes. This only happens for forms
  that contain data of existing objects.
* The controller Zen::Controller::Translations has been removed. Instead of
  using a controller translations are simply dumped as a JSON string in a view.
* Fixed an issue that would cause Zen to crash when trying to store certain data
  using Ramaze::Cache::LRU.
* Custom fields are re-filled with their values whenever a user tries to
  save/create a section entry with invalid/missing data.
* CSRF errors no longer show a plain text message but instead redirect users
  back to the previous page. In case of such an error forms will be re-filled to
  prevent data loss.
* The sort order of menu items increments automatically unless a custom order
  has been specified.
* Various dependencies have been updated.

## 0.3 - November 27th, 2011

* Fixed slug generation.
* Don't load a language file if it is empty.
* Log migration notices using Ramaze::Log.
* Simplified the Rake task for the change list.
* Fixed the rake task for building a change list
* Serialize setting values upon migrating them.
* Log Marshal notices as debug messages.

## 0.3.b1 - November 24th, 2011

* Added a markup option for retrieving entries.

## 0.3.b - November 23rd, 2011

* Started using checkboxes in favor of select boxes as they're easier to use.
* Fixed a small issue that would make it impossible to add/update categories of
  a section entry.
* Core packages no longer include certain modules just to so that they don't
  have to specify the full namespace to a class.
* Added an event system (Zen::Event) and a bucket load of events.
* Merged Zen.init and `Zen.post_init` into Zen.start.
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
* The column `menu_items.order` has been renamed to menu_items.sort_order.
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
* All references to "css\_class" and "css\_id" have been replaced with
  "html\_class" and "html\_id".
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
