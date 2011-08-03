/**
 * Namespace for the Users package. The Users package is used to manage users,
 * user groups and access rules.
 *
 * @author Yorick Peterse
 * @since  0.2.8
 */
var Users = {};

/**
 * Object used when managing access rules in the backend.
 *
 * @author Yorick Peterse
 * @since  0.2.8
 */
Users.AccessRules =
{
    /**
     * Method that can be used to toggle the visibility of a <select>
     * element based on a list of other elements.
     *
     * @author Yorick Peterse
     * @since  0.2.5
     * @param  {array} controllers A list of select boxes containing all 
     * controllers.
     * @param  {string} selected The ID of the select element that has to be
     * displayed.
     */
    toggleSelect: function(controllers, selected)
    {
        // Show the correct box and hide all others
        controllers.each(function(element)
        {
            if ( element.id === selected )
            {
                element.removeClass('hidden').set('disabled', false);
            }
            else
            {
                if ( !element.hasClass('hidden') )
                {
                    element.addClass('hidden');
                }

                element.set('disabled', true);
            }
        });
    }
}
