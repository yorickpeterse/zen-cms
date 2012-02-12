window.addEvent('domready', function()
{
    var widgets    = $('widgets');
    var options_fx = new Fx.Slide('widget_options',
    {
        duration:   'normal',
        transition: Fx.Transitions.Pow.easeOut
    });

    options_fx.hide();

    // The options div is hidden by default, without doing this the div would be
    // displayed for a split second before it's hidden using Fx.Slide. However,
    // Fx.Slide doesn't use the "display" property so it has to be removed
    // manually.
    $('widget_options').setStyle('display', 'block');

    $('toggle_options').addEvent('click', function()
    {
        options_fx.toggle();
    });

    // Allow users to sort the widgets.
    var sortable_widgets = new Sortables('widgets',
    {
        handle:  'header',
        opacity: 0.5,
        revert:  true,
        clone:   true,
        onSort:  function(el)
        {
            var order = {};

            // Build the new order for all the widgets. The "widget_" prefix is
            // removed before the values are being sent to the server.
            sortable_widgets.serialize().clean().each(function(val, index)
            {
                order[val.replace(/widget_/, '')] = index;
            });

            new Request(
            {
                url:    '/admin/widget_order',
                method: 'POST',
                data:   order
            }).send();
        }
    });

    // Update the amount of columns based on the clicked radio button.
    $$('#widget_columns input[type="radio"]').addEvent('click', function()
    {
        var columns = this.get('value');

        widgets.set('class', 'widgets ' + 'columns_' + columns);

        new Request(
        {
            url:    '/admin/widget_columns',
            method: 'POST',
            data:   {columns: columns}
        }).send();
    });

    // Toggle the visibility of a widget and update its state in the database.
    $$('#active_widgets input[type="checkbox"]').addEvent('click', function()
    {
        var el      = $(this.get('value'));
        var name    = this.get('value').replace(/^widget_/, '');
        var enabled = '0';

        if ( this.get('checked') === true )
        {
            enabled = '1';
        }
        else
        {
            if ( el ) el.destroy();
        }

        // Request.HTML doesn't really offer any benefits in this case so using
        // plain Request is fine.
        var request = new Request(
        {
            url:       '/admin/widget_state',
            method:    'POST',
            data:      {widget: name, enabled: enabled},
            onSuccess: function(response)
            {
                if ( response && request.status === 201 )
                {
                    response = Elements.from(response);

                    widgets.adopt(response);
                    sortable_widgets.addItems(response);
                }
            }
        });

        request.send();
    });
});
