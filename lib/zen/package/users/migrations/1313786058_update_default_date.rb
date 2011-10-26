Sequel.migration do
  # Updates the database with the changes specified in the block.
  up do
    users = Zen.database[:users].all

    drop_column(:users, :date_format)
    add_column(:users, :date_format, String, :default => '%Y-%m-%d %H:%M:%S')

    users.each do |user|
      if user[:date_format] == '%Y-%m-%d %H:%I:%S'
        format = '%Y-%m-%d %H:%M:%S'
      else
        format = user[:date_format]
      end

      Zen.database[:users] \
        .filter(:id => user[:id]) \
        .update(:date_format => format)
    end
  end

  # Reverts the changes made in the up() block.
  down do
    users = Zen.database[:users].all

    drop_column(:users, :date_format)
    add_column(:users, :date_format, String, :default => '%Y-%m-%d %H:%I:%S')

    users.each do |user|
      if user[:date_format] == '%Y-%m-%d %H:%M:%S'
        format = '%Y-%m-%d %H:%I:%S'
      else
        format = user[:date_format]
      end

      Zen.database[:users] \
        .filter(:id => user[:id]) \
        .update(:date_format => format)
    end
  end
end
