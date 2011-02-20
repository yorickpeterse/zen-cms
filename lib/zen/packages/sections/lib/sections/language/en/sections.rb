Zen::Language.translation 'sections' do |item|

  item.titles = {
    :index  => 'Sections',
    :edit   => 'Edit Section',
    :new    => 'Add Section'
  }
  
  item.labels = {
    :id                       => '#',
    :name                     => 'Name',
    :slug                     => 'Slug',
    :description              => 'Description',
    :comment_allow            => 'Allow comments',
    :comment_require_account  => 'Comments require an account',
    :comment_moderate         => 'Moderate comments',
    :comment_format           => 'Comment format',
    :custom_field_groups      => 'Custom field groups',
    :category_groups          => 'Category groups',
    :manage_entries           => 'Manage entries'
  }
  
  item.special = {
    :boolean_hash => {"Yes" => true, "No" => false},
    :format_hash  => {"plain" => "Plain", "html" => "HTML", "textile" => "Textile", "markdown" => "Markdown"}
  }
  
  item.tabs = {
    :general            => 'General',
    :comment_settings   => 'Comment Settings',
    :group_assignments  => 'Group Assignments'
  }

  item.messages = {
    :no_sections    => 'It seems you haven\'t created any sections yet.'
  }
  
  item.errors = {
    :new        => "Failed to create a new section.",
    :save       => "Failed to save the section.",
    :delete     => "Failed to delete the section with ID #%s",
    :no_delete  => "You haven't specified any sections to delete."
  }
  
  item.success = {
    :new    => "The new section has been created.",
    :save   => "The section has been modified.",
    :delete => "The section with ID #%s has been deleted."
  }
  
  item.buttons = {
    :new_section     => 'New section',
    :delete_sections => 'Delete selected sections',
    :save_section    => 'Save section'
  }

end
