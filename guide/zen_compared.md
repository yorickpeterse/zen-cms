# Comparing Zen With X

A common question people ask when looking into specific software is "How is this
different/better compared to X?". One might wonder what the differences are
between Zen and Wordpress or Zen and Radiant. This guide is meant to clear
things up a bit.

## Zen vs Wordpress

There are quite a few differences between Zen and Wordpress besides the language
that's being used for the two (PHP for Wordpress, Ruby for Zen). Wordpress at
its core is a blogging engine that was meant to handle blog articles and simple
static pages. Over the years people started writing plugins and it expanded from
a blogging engine into a more general purpose content management system.
However, at its core it still remains a blogging engine and this is something
you'll quickly notice when trying to use it for something other than a blog or a
very basic website.

Another issue with Wordpress is that it has a (in my opinion) horrible code base
as well as a badly designed plugin system that promote bad coding standards and
the mixing of logic and presentation. Wordpress doesn't take full advantage of
the good parts of PHP such as classes and namespaces and instead mostly relies
on the use of global functions.

Zen on the other hand doesn't aim to be a blogging engine or another specific
type of content management application. Instead it tries to make it possible for
you to define your own setup by giving you an easy to use interface and an
organized code base/API for developers to work with, the downside being that in
general Zen is a bit harder to use.

## Zen vs Expression Engine

Zen was heavily inspired by Expression Engine and was initially written to be
"Expression Engine done right". The two have a lot of things in common such as
the ability to create custom fields and sections (called "channels" in EE). Zen
however takes it a step further and allows you to create custom field methods
and types (on top of just fields) as well as having a simpler database design
and a code base that's far more pleasant to work with.

## Zen vs Radiant

While I have to admit that I'm not very familiar with Radiant it appears that
Radiant comes with a rather limited set of features out of the box and tries to
label everything as a page giving you some extra flexibility using so called
"snippets" and "layouts". I can imagine this being easier to use for some but it
also greatly limits the flexibility meaning that developers will often have to
resort to installing or developing (third party) extensions.

Another difference between the two is that Zen uses "Etanni" as a template
engine whereas Radiant uses "Radius". Radius is a template engine that uses HTML
like tags for its logic whereas Etanni uses plain Ruby. Both have their
advantages as well as their drawbacks.

Plain Ruby code is more flexible but it isn't something you want your users to
be able to execute (don't worry, Zen escapes the template tags for you).

Radius on the other hand is something you can use in your content as it can
only execute what you've explicitly defined. The downside of this is that
you'll often end up re-inventing things that can be easily done in plain Ruby.

One thing to keep in mind is that Zen doesn't limit you in terms of what engines
you can use, you can easily use other engines such as Radius or Liquid in
combination with Etanni.
