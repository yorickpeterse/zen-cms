window.addEvent('domready', function()
{
    // Hide the fields that allow a user to pick a user or group
    // for an access rule. Each field (and thus the select element)
    // will be shown when the corresponding radio button is selected.
    var radios = $$('input[name="rule_applies"]');
    var divs   = []
    
    radios.each(function(radio)
    {
        var value = radio.get('value');
        
        if ( value !== "0" )
        {
            value = $(value);

            if ( radio.get('checked') == false )
            {
                value.setStyle('display', 'none'); 
            }
            
            divs.push(value);
        }
        
        radio.addEvent('click', function()
        {
            var radio_value = this.get('value');
            
            divs.each(function(div)
            {
                if ( div.get('id') == radio_value )
                {
                    div.setStyle('display', 'block');
                }
                else
                {
                    div.setStyle('display', 'none');
                }
            });
        });
    });

    var package_select = $('form_package');

    if ( package_select )
    {
        // Hide all the controller select boxes and only show the ones that 
        // belong to the currently selected package.
        var controllers = $$('select.controllers');

        // Show the first box by default
        Users.AccessRules.toggleSelect(
            controllers, package_select.get('value') + '_controllers'
        );

        // When the select element's value is changed the correct controller box 
        // should be displayed and the old one should be hidden
        package_select.addEvent('change', function()
        {
            Users.AccessRules.toggleSelect(
                controllers, this.get('value') + '_controllers'
            );
        });
    }
});
