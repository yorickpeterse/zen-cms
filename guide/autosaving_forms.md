# Automatically Saving Form Data

To make it easier for users to work with their data Zen allows developers to
easily implement a system that makes it possible for form data to be saved
automatically. It is recommended that all forms that create or update data
automatically save their data.

For this to work you must first make it possible for your controllers to respond
to these auto saving actions. This can be done by calling
{Ramaze::Helper::Controller::ClassMethods#autosave} in your controller
declaration. The first parameter is the model to save the data with, the second
an array of columns to save and the third a permission required to perform the
action. For example, the controller {Categories::Controller::CategoryGroups}
calls this method as following:

    autosave Model::CategoryGroup,
      Model::CategoryGroup::COLUMNS,
      :edit_category_group

The array {Categories::Model::CategoryGroup::COLUMNS} contains a list of column
names that can be set by the user.

Once the controller has been prepared you must update your forms so that they
include a ``data-autosave-url`` attribute. This attribute should contain a
string that points to the URL that will receive the form data. If you're using
the autosave method discussed above you should call ``.r(:autosave)`` on your
controller. For category groups this is done as following:

    :'data-autosave-url' => Categories::Controller::CategoryGroups.r(:autosave)

The last step is to make sure that your form has a hidden field with the name
"id", usually this field contains the primary value of an object (the ID). If
this field is empty Zen will **not** save the form automatically, this is to
prevent it from trying to save forms related to non existing objects. Adding
this field is as simple as the following (assuming you're using the BlueForm
helper, which you should):

    f.input_hidden(:id)

And that's it, Zen will take care of the rest for you from this point on. Every
10 minutes Zen will automatically save the form for you and take care of the
logic related to retrieving error messages, updating CSRF tokens and so on.
