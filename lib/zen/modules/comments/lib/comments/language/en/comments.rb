Zen::Language.translation 'comments' do |item|

  item.titles = {
    :index  => 'Comments',
    :edit   => 'Edit Comment'
  }
  
  item.labels = {
    :id         => '#',
    :website    => 'Website',
    :entry      => 'Section entry',
    :email      => 'Email',
    :status     => 'Status',
    :comment    => 'Comment',
    :name       => 'Name',
    :created_at => 'Created',
    :updated_at => 'Updated',
    :defensio_signature => 'Defensio signature'
  }
  
  item.special = {
    :status_hash => {'open' => 'Open', 'closed' => 'Closed', 'spam' => 'Spam'}
  }

  item.messages = {
    :no_comments    => 'No comments have been added yet.'
  }
  
  item.errors = {
    :new                  => "Failed to create a new comment.",
    :save                 => "Failed to save the comment.",
    :delete               => "Failed to delete the comment with ID #%s",
    :no_delete            => "You haven't specified any comments to delete.",
    :invalid_entry        => "The specified section entry is invalid",
    :comments_not_allowed     => "Comments aren't allowed for this section",
    :comments_require_account => "This section requires you to be logged in in order to post a comment",
    :no_api_key               => "You need to specify an API key for the Defension system in your settings panel.",
    :defensio_status          => "The comment could not be saved due to a problem with the Defensio server."
  }
  
  item.success = {
    :new      => "The new comment has been created.",
    :save     => "The comment has been modified.",
    :delete   => "The comment with ID #%s has been deleted.",
    :moderate => "The comment has been posted but must be approved by an administrator before it's displayed."
  }
  
  item.buttons = {
    :delete_comments => 'Delete selected comments',
    :save_comment    => 'Save comment'
  }
end