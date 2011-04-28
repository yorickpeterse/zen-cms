window.addEvent('domready', function()
{
    /**
     * Show a notification whenever we find an error, success or notice hash in the 
     * Zen.Flash object.
     */
    if ( Zen.Flash.notification )
    {
        new Zen.Notification(
        {
            title:   Zen.Flash.notification.title,
            content: Zen.Flash.notification.content,
            image:   Zen.Flash.notification.image,
            sticky:  Zen.Flash.notification.sticky
        });
    }
    
    /**
     * Enable the automatic checking of all checkboxes in a table with a class of "table". 
     * Perhaps I'll use a class for this in the future but for now this is good enough.
     */
    var tables = $$('.table');
    
    if ( tables.length > 0 )
    {
        tables.each(function(table)
        {
            var check_all = table.getElement(
                'thead tr th:first-child input[type=checkbox]'
            );
            
            check_all.addEvent('click', function()
            {
                var check_all_status = check_all.get('checked');
                
                tables.getElements(
                    'tbody tr td:first-child input[type=checkbox]'
                ).each(function(c)
                {
                    c.set('checked', check_all_status);
                });
            });
        });
    }

    /**
     * Create a new instance of the Tabs class. This will create a regular tab system for
     * the CSS selector "div.tabs ul".
     */
    var tab_selector = 'div.tabs ul';
    var tab_elements = $$(tab_selector).length;

    yepnope(
    {
        test    : !Zen.Tabs && tab_elements > 0,
        yep     : ['/admin/css/tabs.css', '/admin/js/zen/tabs.js'],
        complete: function()
        {
            // Double check there are any elements
            if ( tab_elements > 0 )
            {
                new Zen.Tabs(tab_selector);
            }
        }
    });
    
    /**
     * Initialize our editor for all elements with a class of "visual_editor" and 
     * retrieve the editor format from the attribute "data-format".
     */
    var editor_elements = $$('.visual_editor');

    if ( editor_elements.length > 0 )
    {
        // Load the base class after which we'll figure out what drivers to load
        yepnope(
        {
            test    : Zen.Editor,
            nope    : ['/admin/css/editor.css', '/admin/js/zen/editor/base.js'],
            complete: function()
            {
                // Right, we now have our base class in place, let's find out what drivers
                // to load.
                editor_elements.each(function(editor)
                {
                    var driver = editor.get('data-format');

                    // Screw you, you should've set the attribute!
                    if ( !driver )
                    {
                        return console.error(
                            "Missing attribute data-format for the editor with ID " 
                            + editor.get('id')
                        );
                    }
                    
                    // Load the correct driver and initialize it once it's loaded
                    yepnope(
                    {
                        test    : Zen.Editor[driver.capitalize()],
                        nope    : ['/admin/js/zen/editor/drivers/' + driver + '.js'],
                        complete: function()
                        {
                            new Zen.Editor.Base(
                                '.visual_editor[data-format="' + driver + '"]',
                                {
                                    format: driver
                                }
                            ).display();
                        }
                    });
                });
            }
        });
    }

    /**
     * Initializes a datepicker object whenever it's loaded and the correct element was 
     * found.
     */
    var date_elements = $$('input[type="text"].date');

    if ( date_elements.length > 0 )
    {
        yepnope(
        {
            test    : typeof Picker === 'undefined',
            yep     : ['/admin/css/datepicker.css', '/admin/js/vendor/datepicker.js'],
            complete: function()
            {
                new Picker.Date(date_elements,
                {
                    timePicker:  true,
                    pickerClass: 'datepicker',
                    format:      '%Y-%m-%d %H:%M:%S'
                });
            }
        });
    }
});
