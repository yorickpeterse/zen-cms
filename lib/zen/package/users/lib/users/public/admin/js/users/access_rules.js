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
});
