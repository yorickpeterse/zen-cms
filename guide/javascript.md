# Javascript API

Zen comes with a pretty good Javascript API that's based on the
[Mootools][mootools]. This API allows you to display modal windows, markup
editors and so on. On top of that you're free to use everything Mootools and
it's community has to offer.

<div class="note todo">
    <p>
        <strong>Note</strong>: Whenever you're creating Javascript files you
        should use 4 spaces per indentation and refrain from using tabs. 4
        spaces are used as 2 spaces are generally harder to read due to
        Javascript using curly brackets.
    </p>
</div>

## Creating Classes

Mootools has a wonderful system that allows you to easily create classes. The
one thing to remember when creating classes is that you should *always* declare
them under a certain namespace. Not doing so might lead to collisions with
classes created by other developers.

Creating a class (including a namespace) works like the following:

    namespace('Foobar');

    Foobar.ClassName = new Class(
    {
        initialize: function()
        {

        }
    });

This allows you to access your class as following:

    var instance = new Foobar.ClassName();

The namespace you're using doesn't really matter as long as you **do not** use
the "Zen" namespace, it's reserved for all the classes that ship with Zen.

It's also important to remember that there's no guarantee Javascript (and CSS)
files are loaded in a particular order. Because of that you should always wrap
your code (except for class declarations and such) in the following code:

    window.addEvent('domready', function()
    {
        // Do something funky!
    });

This function will be executed once the DOM (and thus all the resources) are
fully loaded.

## Available Classes

Out of the box the following classes are available:

* {file:javascript/zen_window Zen.Window}
* {file:javascript/zen_tabs Zen.Tabs}
* {file:javascript/zen_hash Zen.Hash}
* {file:javascript/zen_editor Zen.Editor}
* {file:javascript/zen_htmltable Zen.HtmlTable}
* {file:javascript/zen_autosave Zen.Autosave}
* {file:javascript/zen_form Zen.Form}

The following third-party classes are also provided:

* Picker
* Picker.Date
* Picker.Attach

## Datepickers

Zen comes with a version of [Mootools Datepicker][mootools datepicker]. To load
this datepicker you must load the asset group ``:datepicker`` in your
controller:

    class Posts < Zen::Controller::AdminController
      map '/admin/posts'

      load_asset_group [:datepicker], [:new, :edit]

      def new

      end

      def edit(id)

      end
    end

For more information on loading assets see {file:asset_management.md Asset
Management}.

In order to use the datepicker you'll have to add the class "date" to your input
elements:

    <input type="text" name="my_date" class="date" />

In order to customize the datepicker you can set the following attributes:

* data-date-format: a custom date format to use for input and output
  values. Set to the format as defined in ``Zen.date_format`` by default.
* data-date-time: when set to "1" or "true" users can also select a time. Set to
  false by default.
* data-date-min: string containing the minimum date.
* data-date-max: string containing the maximum date.

An example of using these attributes is the following:

    <input type="text" name="my_date" class="date" data-date-format="%d-%m-%Y"
    data-date-min="01-01-2012" data-date-max="01-01-2013" />

[mootools]: http://mootools.net/
[mootools datepicker]: https://github.com/arian/mootools-datepicker
