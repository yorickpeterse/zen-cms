# Zen.HtmlTable

The class Zen.HtmlTable was introduced in Zen 0.2.8 and makes it possible to
sort tables by their columns, check all checkboxes in the first column of a
table and it highlights odd rows. Generally you don't need to use this class
itself but instead you'll be using the markup it accepts in order to modify it's
behavior.

The basic markup for this class is very simple, in fact, it's nothing more than
a regular table with a ``<thead>`` element:

    <table>
        <thead>
            <tr>
                <th>#</th>
                <th>Name</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>2</td>
                <td>Ruby</td>
            </tr>
        </tbody>
    </table>

Zen will automatically detect and use the table and you're good to go. If you
want to modify the behavior you can use a few attributes on certain elements of
the table. The following attributes can be applied to the ``<table>`` element
itself:

* data-sort-index: the index of the ``<th>`` element to sort the table on by
  default. By default this is set to 1 as all tables have a checkbox in the
  first column of each row.

The following attributes can be set on each ``<th>`` element:

* data-sort-parser: the name of the parser to use for sorting the columns. This
  option is directly passed to HtmlTable.Sort and can be any of the parsers
  Mootools has to offer (or one you wrote yourself).

Example:

    <table data-sort-index="1">
        <thead>
            <tr>
                <th>#</th>
                <th data-sort-parser="usernames">Name</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>2</td>
                <td>Ruby</td>
            </tr>
        </tbody>
    </table>

If you want to create a table that should be ignored by Zen.HtmlTable simply
give the ``<table>`` element a class of ``no_sort``:

    <table class="no_sort">
        <thead>
            <tr>
                <th>#</th>
                <th>Name</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>2</td>
                <td>Ruby</td>
            </tr>
        </tbody>
    </table>

This class can also be applied to ``<th>`` elements to ignore just that column
rather than the entire table.
