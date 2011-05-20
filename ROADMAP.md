# Roadmap

Please note that the release dates in this roadmap may and most likely will change from
time to time. List items that contain a "(!)" are considered to be important and should
be solved/added before any of the other items. Items containing "(?)" are considered
to be unverified/undecided and might not be added/completed at all.

## Planned Releases

### 0.3 - June 2011

* Website completely up and running. (!)
* Translation system for the Javascript used in the backend.
* Documentation online.

### 0.2.6 - May 2011

* Implement something like Sprockets that can combine CSS/Javascript files and ditch the
rather crappy helper Ramaze::Helper::Asset.
* Add some sort of UI framework making it easier to create modal windows, tables, etc.
* Improve/overhaul the text editor used in the backend, it's rather basic at the moment.
* Improve the comment system so that people can save their data in some way (perhaps 
allow people to register). 
* Deprecate Zen::Plugin::Helper in favor of Zen::Validation.
* Remove Zen::Database as all it currently does is pretty much copying the behavior of
Sequel.connect.
* Use Zen::Plugin::Controller opposed to Innate::Trinity whenever trying to access
controller specific data outside of controllers.

### 0.2.5 - April 2011

* Replaced Liquid by a combination of Etanni and a set of plugins.
* Allow developers to register and load Javascript and CSS files globally.
* Replace all CSS files by Less CSS if this turns out to have an advantage over regular
css files. (?)
* Remove the methods from Settings::Model::Setting that are used to generate the possible
values for system settings. These should go in a plugin or something similar.

### 0.2.4 - March 2011

* Liquid tags work when caching is enabled.
* Compatibility with 1.9 and 1.9.1. (?)
* A working (although probably rough) plugin system to extend the inner parts of Zen. 
An example of a plugin would be something that allows the use of Akismet for comments
rather than Defensio.

### 0.2 - March 2011

* General code improvements.
* Navigation module for the frontend.
* Improved Liquid tags.
* A working datepicker
* Refilling forms in case of errors (!)

### 0.1a - February 2011

The first public alpha released, mainly meant to give people and idea of what Zen is 
all about.
