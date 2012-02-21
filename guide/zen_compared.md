# Comparing Zen With Others

A common question people ask when looking into specific software is "How is this
different/better compared to X?". One might wonder what the differences are
between Zen and Wordpress or Zen and Radiant. This guide is meant to clear
things up a bit.

Do note that since I wrote Zen my opinion is more than likely biased.

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

### Installation

Unlike Zen Wordpress isn't distributed using a package manager, instead you have
to manually download, extract and install a compressed archive. In its most
basic form you'd have to run the following commands to get a copy of Wordpress:

    $ wget http://wordpress.org/latest.tar.gz
    $ tar -xvf latest.tar.gz
    $ cd wordpress/

This process is not only tiring but also makes it harder to upgrade existing
installations.

Zen is distributed using Rubygems and thus all you need to run in order to
install it is the following command:

    $ gem install zen

If you want to update Zen you simply run ``gem update zen`` instead.

## Zen vs Expression Engine

Zen was heavily inspired by Expression Engine and was initially written to be
"Expression Engine done right". The two have a lot of things in common such as
the ability to create custom fields and sections (called "channels" in EE). Zen
however takes it a step further and allows you to create custom field methods
and types (on top of just fields) as well as having a simpler database design
and a code base that's far more pleasant to work with.

Another big difference between the two is that Expression Engine costs money and
is not open source, Zen on the other hand is completely free and licensed under
the MIT license. This license gives you the freedom to use Zen for any project
(both open source and proprietary) without the drawbacks of licenses such as the
GPL.

### Installation

Similar to Wordpress you'll have to download a copy of Expression Engine
yourself. However, EE comes with the requirement of having a user account as
well as a credit card since Expression Engine is not free nor open source.
Installing EE comes down to the following:

1. Register for an account
2. Buy a license using a credit card
3. Download a .zip archive (I'm not sure if they offer Tarballs)
3. Extract the archive

Again just like Wordpress this has to be done for every installation (except for
the registration part) though this depends on the license you've chosen.

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

### Installation

Just like Zen Radiant can be installed using Rubygems by running the following
comamnd:

    $ gem install radiant

Other than using a different gem name there are no differences between Zen and
Radiant when it comes down to installing the two.

## Zen vs Refinery CMS

I have to admit that I have very little experience with Refinery CMS. What I
noticed from using the demo was that the interface it uses looks rather boring
and doesn't feel very pleasant to use. The settings overview is rather confusing
and managing settings happens in modal windows while managing other rows, such
as users, happens on an entirely new page.

Another thing I noticed is that Refinery CMS, just like Wordpress and Expression
Engine, assumes you'll only use two markup formats: plain text and HTML. A big
problem with common WYSIWYG editors such as CKEditor and TinyMCE is that the
markup they generate is either plain incorrect or otherwise disgusting. CKEditor
for example has a tendency to insert empty ``<p>`` or ``<div>`` elements in
your content for no apparent reason.

Out of the box Zen offers support for plain text, HTML, Markdown and Textile
with the ability to easily add your own markup formats. The text editor was
written with this in mind and produces very clean markup, the drawback being
that it does not (and most likely never will) support WYSIWYG features. The
closest thing to this feature is the "Preview" button which opens a modal window
with the HTML that was generated based on the used markup.

Probably the biggest difference of all is that Refinery CMS does not appear to
have a very flexible content model (out of the box at least). There are a few
content types such as "Pages", "Images" and "Inquiries" but it's not very clear
how flexible (or not) these content types are.

### Installation

Similar to Zen and Radiant Refinery CMS is also installed using Rubygems, this
can be done by running the following command:

    $ gem install refinerycms

Besides the Gem name there are no other differences in the installation process
that I know of.

## Zen vs Locomotive CMS

Locomotive CMS is a rather new application that was released somewhere in the
end of 2011. It has a similar system like Zen allowing you to create custom
fields however based on the little experience that I have with Locomotive I'd
say it's far more limited. I couldn't figure out if there was the ability to add
your own field types or group them together. Locomotive also doesn't offer a
flexible way of defining rules for custom fields other than allowing users to
specify that a certain field is required.

The interface used by Locomotive was rather annoying to use and doesn't appear
to be very useful when presenting large amounts of content due to the fixed
width of the design. To be honest I'm quite amazed by this since the designer,
Sacha Grief, seems to be more than capable of designing good looking and useful
interfaces.

Unlike Zen Locomotive doesn't use a relational database but instead uses
MongoDB. Some might argue that this is better (or worse) but I'm personally not
too sure about it. I've heard great things about MongoDB but I've also heard and
read very bad things about it. When I tried it myself I wasn't too impressed
with it, it gives me the idea somebody wanted to write a relational database
engine that wasn't a relational database engine.

### Installation

The installation process of Locomotive looks rather, well, stupid. Instead of
allowing you to install it using Rubygems and be done with it you have to go
through multiple steps, starting with setting up a bare Rails installation,
adding Locomotive to your Gemfile and so on. In total there's about 6 steps
needed to install it. See
<http://www.locomotivecms.com/support/installation/engine> for more information.

Compared with Zen, which only requires you to run ``gem install zen``, I wonder
why they ever thought it was a good idea to require so many steps when it can be
done so much easier.
