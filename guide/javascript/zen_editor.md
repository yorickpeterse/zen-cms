# Zen.Editor

Zen.Editor is the main class used for the markup editor that can be used to more
easily insert markup for all supported languages into a text area. By default
Zen will automatically use the markup editor for all ``textarea`` elements with
a class of ``visual_editor``. The format used for the markup is retrieved from
the column ``data-format`` (this column is required). The attribute
``data-format`` should contain the name of the markup engine to use as defined
in ``Zen.Editor.drivers``. Currently the following are supported:

* markdown
* textile

If an unknown driver is specified the default driver (HTML) will be used
instead.

The markup required for Zen to automatically use the markup editor looks like
the example below.

    <textarea class="visual_editor" data-format="markdown"></textarea>

If you want to manually create an instance of ``Zen.Editor`` you can still do so
but due to the way the system works you shouldn't directly create an instance of
the class as this will prevent the editor from automatically using the correct
driver class. You should use ``Zen.Editor.init`` instead. This method has the
following syntax:

    var editor = Zen.Editor.init(driver, element[, options, buttons]);

The first parameter is a string containing the name of the driver to use. The
second parameter can either be a CSS selector, a collection of elements or a
single element. If the parameter is a CSS selector or a collection of elements
the **first** element will be used, all others will be ignored. The last two
parameters are used for customized options as well as adding custom buttons to
the editor. Currently the editor only supports the following two options:

* width: sets a minimum width on the textarea element.
* height: sets a minimum hight on the textarea element.

Buttons can be added by setting the last parameter to an array. Each button has
the same format as the buttons used in Zen.Window:

    {
      name:   'foobar',
      label:  'Foobar',
      onClick: function() {}
    }

Note that unlike Zen.Window these buttons can't be set in the options object
under the key "buttons". This is because the Options class of Mootools doesn't
actually merge options but instead overwrites existing ones. This would mean
that it would be more difficult to add a default set of buttons as well as
custom ones. Most likely this will change in the future once I find out what the
best way of doing this would be.

Example:

    var editor = Zen.Editor.init(
        'markdown',
        'div#text_editor',
        {
            width: 400
        },
        [
            {
                name:    'custom',
                label:   'Custom',
                onClick: function(editor)
                {
                    console.log("This is a custom button!");
                }
            }
        ]
    );

Functions used for buttons take a single parameter which will contain an
instance of the editor the button belongs to. This makes it easy to insert text
into the textarea:

    function(editor)
    {
        editor.insertAroundCursor({before: '<!--', after: '-->'});
    }
