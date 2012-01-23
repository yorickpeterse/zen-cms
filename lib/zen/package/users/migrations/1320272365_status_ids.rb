Sequel.migration do
  up do
    users = Zen.database[:users].all

    create_table(:user_statuses) do
      primary_key :id

      String :name, :null => false
      TrueClass :allow_login, :default => false
    end

    alter_table(:users) do
      drop_column(:status)

      add_foreign_key(
        :user_status_id,
        :user_statuses,
        :on_delete => :cascade,
        :on_update => :cascade,
        :key       => :id
      )
    end

    Zen.database[:user_statuses].insert_multiple([
      {:name => 'active', :allow_login => true},
      {:name => 'closed'}
    ])

    open   = Zen.database[:user_statuses].filter(:name => 'active').all[0]
    closed = Zen.database[:user_statuses].filter(:name => 'closed').all[0]

    # Migrate the existing statuses.
    users.each do |user|
      status = user[:status] == 'open' ? open[:id] : closed[:id]

      Zen.database[:users] \
        .filter(:id => user[:id]) \
        .update(:user_status_id => status)
    end
  end

  down do
    users  = Zen.database[:users].all
    open   = Zen.database[:user_statuses].filter(:name => 'active').all[0]
    closed = Zen.database[:user_statuses].filter(:name => 'closed').all[0]

    alter_table(:users) do
      if Zen.database.database_type.to_s.include?('mysql')
        drop_constraint(:users_ibfk_1, :type => :foreign_key)
      end

      drop_column(:user_status_id)
      add_column(:status, String, :null => false, :default => 'open')
    end

    drop_table(:user_statuses)

    # Put the old statuses back in place.
    users.each do |user|
      status = user[:user_status_id] == open[:id] ? 'open' : 'closed'

      Zen.database[:users] \
        .filter(:id => user[:id]) \
        .update(:status => status)
    end
  end
end
