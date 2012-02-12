"use strict";

/**
 * Allows users to sort menu items and assign them to parent items by dragging
 * them.
 *
 * @since 09-02-2012
 */
window.addEvent('domready', function()
{
    var container = $('menu_items');

    // NestedSortables triggers events whenever all child elements of a list are
    // clicked. This prevents that from happening which in turn leads to fewer
    // async calls to the server.
    $$('.menu_item input, .menu_item a').addEvent('mousedown', function(e)
    {
        e.stopPropagation();
    });

    if ( container && container.get('data-editable') !== 'false' )
    {
        var tree = new NestedSortables('menu_items',
        {
            ghostOffset: {x: 0, y: 0},
            handleClass: 'menu_item',
            onComplete:  function()
            {
                new Request(
                {
                    url:    '/admin/menu-items/tree',
                    method: 'POST',
                    data:   {menu_items: tree.serializeArray()}
                }).send();
            }
        });
    }
});
