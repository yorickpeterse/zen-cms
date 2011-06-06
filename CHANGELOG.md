## 0.2.6.1 - June 1st, 2011

* Dropped Zen.settings and modified the settings plugin so that it works properly when
  using a multi-process based environment such as Unicorn.

## 0.2.6 - May 29th, 2011

* Zen is now using RVM for gem management and such.
* Began working on making Zen compatible with at least JRuby. Rubinius isn't worth the
  effort at this time.
* Removed Ramaze::Helper::Common.notification in favor of Ramaze::Helper::Message.
* Dropped Zen::Database, Zen::Settings and most of the options in favor of instance
  variables set in the main Zen module. See commit 
  [d40ee1c2e518a323b2983e1bcfb7a0d863bf3b2f][d40ee1c2e518a323b2983e1bcfb7a0d863bf3b2f] 
  for more information.
* Translated Zen to Dutch.
* Re-organized the application prototypes to make them easier to use/understand.
* Implemented the anti-spam system as a plugin and added a decent XSS protection system
  using Loofah.
* Various changes to the Javascript classes.

[d40ee1c2e518a323b2983e1bcfb7a0d863bf3b2f]: https://github.com/zen-cms/Zen-Core/commit/d40ee1c2e518a323b2983e1bcfb7a0d863bf3b2f