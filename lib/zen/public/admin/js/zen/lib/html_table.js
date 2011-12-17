/**
 * Zen.HtmlTable is an extension to the HtmlTable class provided by Mootools
 * More. This extension makes it possible to sort tables, check all checkboxes
 * in the first column and so on.
 *
 * ## Usage
 *
 * The markup required by this class is very basic, in fact, by default it
 * doesn't need any special markup at all. A simple table with a <thead> element
 * will do just fine:
 *
 * <table id="some_table">
 *     <thead>
 *         <tr>
 *             <th>#</th>
 *             <th>Name</th>
 *         </tr>
 *     </thead>
 *     <tbody>
 *         <tr>
 *             <td>10</td>
 *             <td>Yorick</td>
 *         </tr>
 *     </tbody>
 * </table>
 *
 * Creating the Javascript object for this table would work as following:
 *
 *     var table = new Zen.HtmlTable($('some_table'));
 *
 * For more information on the available options (which can be set in the second
 * parameter just like HtmlTable) see HtmlTable and HtmlTable.Sort.
 *
 * @since  0.2.8
 */
Zen.HtmlTable = new Class(
{
    Extends: HtmlTable,

    /**
     * Creates a new instance of the class and calls the required methods to
     * allow users to check all checkboxes in a table.
     *
     * @since  0.2.8
     * @see    HtmlTable.initialize()
     */
    initialize: function(element, options)
    {
        options = Object.merge(this.generateOptions(element), options);

        this.parent(element, options);

        this.enableCheck();
    },

    /**
     * Given an HTML element this method returns an object containing various
     * options that can be passed to the HtmlTable class. These options are set
     * using various HTML attributes.
     *
     * The following attributes can be set on the <table> element:
     *
     * * data-sort-index: the index of the column to sort the table on by
     *   default, set to 1 by default.
     *
     * The following attributes can be set on each <th> elements:
     *
     * * data-sort-parser: the name of the parser to use for the column.
     *
     * @since  0.2.8
     * @param  {element} element An HTML element that represents a single table.
     * @return {object}
     */
    generateOptions: function(element)
    {
        // Set the default options
        var options = {
            classSortSpan   : 'sort',
            classSortable   : 'sortable',
            classHeadSort   : 'asc',
            classHeadSortRev: 'desc',
            classNoSort     : 'no_sort',
            classCellSort   : 'sorted',
            sortable        : true,
            parsers         : []
        };

        // Determine the column to sort on by default.
        options.sortIndex = element.get('data-sort-index') || 1;

        if ( typeOf(options.sortIndex) === 'string' )
        {
            options.sortIndex = options.sortIndex.toInt();
        }

        // Add all custom parsers
        element.getChildren('thead tr th').each(function(th, index)
        {
            var parser = th.get('data-sort-parser');

            if ( parser )
            {
                options.parsers[index] = parser;
            }
        });

        return options;
    },

    /**
     * Creates the required events to allow a user to check a single checkbox in
     * the table heading which in turn checks all the checkboxes for that column
     * in each table row.
     *
     * @since  0.2.8
     */
    enableCheck: function()
    {
        var element   = this.element;
        var check_all = element.getElement(
            'thead tr th:first-child input[type="checkbox"]'
        );

        if ( check_all )
        {
            check_all.addEvent('click', function()
            {
                var checked = check_all.get('checked');

                element.getElements(
                    'tbody tr td:first-child input[type="checkbox"]'
                ).each(function(checkbox)
                {
                    checkbox.set('checked', checked);
                });
            });
        }
    }
});
