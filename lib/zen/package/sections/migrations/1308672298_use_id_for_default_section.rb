Sequel.migration do
  # Updates the database with the changes specified in the block.
  up do
    # Make sure the settings table has been migrated
    ::Zen::Plugin.plugin(:settings, :migrate)

    if !Zen.database[:sections].all.empty?
      default_section = Zen.database[:settings] \
        .filter(:name => 'default_section') \
        .all[0][:value]

      default_section = Zen.database[:sections] \
        .filter(:slug => default_section) \
        .all[0][:id]

      # Change the slug to an ID
      Zen.database[:settings].filter(:name => 'default_section') \
        .update(:value => default_section)
    end
  end

  # Reverts the changes made in the up() block.
  down do
    default_section = Zen.database[:settings] \
      .filter(:name => 'default_section') \
      .all[0][:value]

    section = Zen.database[:sections] \
      .filter(:id => default_section) \
      .all[0]

    if !section.nil?
      default_section = section[:slug]

      # Change the ID back to a slug
      Zen.database[:settings].filter(:name => 'default_section') \
        .update(:value => default_section)
    end
  end
end
