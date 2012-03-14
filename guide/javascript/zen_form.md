# Zen.Form

Zen.Form is a class used for adding various dynamic features to HTML forms
such as automatically saving the data and handling validation errors using
the HTML5 constraints API.

For the features related to the HTML5 constraints API to work properly users
should be using a modern browser. If this API is not implemented it will be
silently ignored. Automatically saving data is supported regardless of the
existence of this API and is handled by Zen.Autosave.

## Usage

In order to use this class you'll have to create a new instance of it and
pass an instance of Element to it (an instance for a ``<form>`` element):

    new Zen.Form($('my_form'));

By passing and object to the second parameter you can customize various parts
of this class. The following options are available:

* autosave_attribute: name of the attribute that contains the URL to send
  requests to when automatically saving form data. This option is set to
  "data-autosave-url" by default.
* tabs_selector: a CSS selector used to determine the tabs for the form, set
  to "div.tabs ul" by default.
* error_class: the primary class to use for error indicators in a tab, set to
  "tab_error" by default.

An example of setting one of these options is the following:

    new Zen.Form($('my_form'), {error_class: 'custom_tab_error'});

Keep in mind that out of the box there's no need to manually use this class,
Zen already does this for you.

## Tabs and Errors

This class makes it easier for users to nice form errors. This is achieved by
showing a small error icon in a tab of which the corresponding tab field
contains a number of invalid form elements. For this to work properly you
should add the class "tab_field" to each tab field:

    <div id="general" class="tab_field">
        <!-- Tab field's content -->
    </div>
