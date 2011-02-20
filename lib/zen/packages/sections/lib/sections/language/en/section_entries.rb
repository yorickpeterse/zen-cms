Zen::Language.translation 'section_entries' do |item|

  item.titles = {
    :index  => 'Entries',
    :edit   => 'Edit Entry',
    :new    => 'Add Entry'
  }
  
  item.labels = {
    :id         => '#',
    :title      => 'Title',
    :slug       => 'Slug',
    :status     => 'Status',
    :created    => 'Created at',
    :updated    => 'Updated at',
    :author     => 'Author'
  }
  
  item.special = {
    :status_hash => {'draft' => 'Draft', 'published' => 'Published'},
  }
  
  item.tabs = {
    :basic      => 'Basic',
    :categories => 'Categories'
  }

  item.messages = {
    :no_entries    => 'No section entries have been created yet.',
    :no_categories => 'No categories have been assigned to the current section.'
  }
  
  item.errors = {
    :new        => 'Failed to create a new entry.',
    :save       => 'Failed to save the entry.',
    :delete     => 'Failed to delete the entry with ID #%s',
    :no_delete  => 'You haven\'t specified any entries to delete.'
  }
  
  item.success = {
    :new    => 'The new entry has been created.',
    :save   => 'The entry has been modified.',
    :delete => 'All selected entries have been deleted.'
  }
  
  item.buttons = {
    :new_entry      => 'New entry',
    :delete_entries => 'Delete selected entries',
    :save_entry     => 'Save entry'
  }

end
