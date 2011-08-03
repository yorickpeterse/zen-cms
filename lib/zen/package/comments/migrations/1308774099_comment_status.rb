Sequel.migration do
  # Updates the database with the changes specified in the block.
  up do
    create_table(:comment_statuses) do
      primary_key :id

      String :name, :null => false, :unique => true
    end

    # Get all the current comments so we can update the statuses
    comments = Zen.database[:comments].all

    # Replace the old status column
    drop_column(:comments, :status)

    alter_table(:comments) do
      add_foreign_key(
        :comment_status_id,
        :comment_statuses,
        :on_delete => :cascade,
        :on_update => :cascade,
        :key       => :id
      )
    end

    # Insert the possible statuses and migrate existing statuses over to the IDs
    ['open', 'closed', 'spam'].each do |status|
      status_id = Zen.database[:comment_statuses].insert({:name => status})

      comments.each do |comment|
        if comment[:status] === status
          Zen.database[:comments].filter(:id => comment[:id]) \
            .update(:comment_status_id => status_id)
        end
      end
    end
  end

  # Reverts the changes made in the up() block.
  down do
    statuses = {}
    comments = Zen.database[:comments].all

    Zen.database[:comment_statuses].all.each do |status|
      statuses[status[:id]] = status[:name]
    end

    # Put the old columns back in place
    drop_column(:comments, :comment_status_id)
    add_column(:comments, :status, String, :default => 'closed')

    # Put the old statuses back in place
    comments.each do |comment|
      Zen.database.filter(:id => comment[:id]) \
        .update(:status => statuses[comment[:comment_status_id]])
    end

    drop_table(:comment_statuses)
  end
end
