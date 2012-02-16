# Zen.Tabs

Zen.Tabs can be used to create a tab based navigation menu. Because Zen already
uses this class for all elements that match the selector ``div.tabs ul`` it's
usually not required to manually create an instance of this class.

The syntax of creating an instance of this class looks like the following:

    var tabs = new Zen.Tabs(selector[, options]);

The first parameter is a CSS selector, the second parameter is an object
containing various options to customize the instance. Note that the selector
used should result in a number of ``ul`` elements, not ``div`` elements (or any
other elements).

A short example looks like the following:

    var tabs = new Zen.Tabs('div.my_tabs ul');

The following options can be used to customize the tabs:

* default: a selector used to indicate what tab element should be selected by
  default. Set to ``li:first-child`` by default.

For the tabs system to work properly you'll need to use the right markup for
your fields. Luckily this is as simple as creating a ``<div>`` (or another type
of element) and setting an ID for that element:

    <!-- The markup for your tabs -->
    <div class="tabs">
        <ul>
            <li>
                <a href="#some_id">Some ID</a>
            </li>
        </ul>
    </div>

    <!-- The field to show/hide -->
    <div id="some_id">

    </div>

Keep in mind that for the tab system to work properly the URLs for each tab
should start with a hash sign.
