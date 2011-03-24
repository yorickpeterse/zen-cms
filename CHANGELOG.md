# Changelog

## 0.2.4 - March 27th, 2011

* Fix an issue that would prevent migrations from being executed in the correct order.
* Fixed a small translation bug in the section entries translation file.
* Restyled the footer in the admin panel.
* Removed the requirement of having to specify the type of package/extension.
* Navigation items will now be hidden according to the user's permissions.
* Split packages into packages, themes and plugins. This makes it much easier to extend
small features such as the markup generator and the comment validation system

## 0.2 - March 20th, 2011

* Added a package for managing navigation items.
* Introduced a new language system using YAML files instead of Ruby files.
* Added a datepicker for date fields.
* Improved several existing Liquid tags.
* Form data is no longer lost in case of an error. 
* Converted all markup from Textile to Markdown.
* Replaced Bacon by RSpec 2 and Webrat.
* Replaced Rake by Thor.
* Cleaned up a lot of code.

## 0.1a - February, 5th 2011

First public alpha release. Many things are still missing at this point. 
