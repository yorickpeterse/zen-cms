# Hacking/Contributing

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

[nvie branch model]: http://nvie.com/posts/a-successful-git-branching-model/
