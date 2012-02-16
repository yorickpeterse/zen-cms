# Zen.Autosave

Zen.Autosave automatically saves form data at a given interval. Automatically
saving form data makes it more pleasant for users to work with their data as
the risk of data loss is minimized.

Basic usage of this class is as following:

    new Zen.Autosave(
        $('my_form'),
        'http://localhost/admin/category-groups/autosave'
    );

When creating a new instance of this class you are required to specify a
single Element instance as well as the URL to submit the data to. The element
is specified as the first parameter, the URL as the second one. The optional
third parameter can be used for setting optional options such as the interval
and the HTTP method to use for submitting the data.

By default the interval is set to 10 minutes, this can be changed as
following:

    new Zen.Autosave(element, url, {interval: 300000});

This would cause the form data to be saved every 5 minutes instead of every
10 minutes.
