##
# Task group for database related tasks such as migrating and removing the database.
#
# @author Yorick Peterse
# @since  0.2.5
#
namespace :db do

  desc 'Migrates the database to the newest version'
  task :migrate do
    if Zen::Package::Registered.empty?
      abort "No packages have been registered."
    end

    # Get the details required to run a migration
    Zen::Package::Registered.each do |name, pkg|
      # Get the migration directory
      if pkg.respond_to?(:migration_dir) and !pkg.migration_dir.nil?
        dir = pkg.migration_dir
      else
        dir = pkg.directory + '/../../migrations'
      end

      if !File.directory?(dir)
        abort "The migration directory #{dir} doesn't exist."
      end

      table = 'migrations_package_' + pkg.name.to_s

      # Migration time
      Zen.database.transaction do
        Sequel::Migrator.run(Zen.database, dir, :table => table)
        Ramaze::Log.info("Successfully migrated \"#{pkg.name}\"")
      end
    end
  end

  desc 'Deletes the entire database'
  task :delete do
    if Zen::Package::Registered.empty?
      abort "No packages have been registered."
    end

    packages = Zen::Package::Registered.map { |name, pkg| [name, pkg] }.reverse

    # Get the details required to run a migration
    packages.each do |name, pkg|
      # Get the migration directory
      if pkg.respond_to?(:migration_dir) and !pkg.migration_dir.nil?
        dir = pkg.migration_dir
      else
        dir = pkg.directory + '/../../migrations'
      end

      if !File.directory?(dir)
        abort "The migration directory #{dir} doesn't exist."
      end

      table = 'migrations_package_' + pkg.name.to_s

      # Migration time
      Zen.database.transaction do
        Sequel::Migrator.run(Zen.database, dir, :table => table, :target => 0)
        Zen.database.drop_table(table)

        Ramaze::Log.info("Successfully uninstalled \"#{pkg.name}\"")
      end
    end
  end

  desc 'Creates a default administrator with a random password'
  task :user do
    password = (0..12).map do
      letter = ('a'..'z').to_a[rand(26)]
      number = (0..9).to_a[rand(26)]
      letter + number.to_s
    end.join
  
    # Only insert the user if it isn't there yet.
    user  = Users::Model::User[:email => 'admin@website.tld']
    group = Users::Model::UserGroup[:slug => 'administrators']
    
    if group.nil?
      group = Users::Model::UserGroup.new(
        :name => 'Administrators',
        :slug => 'administrators', :super_group => true
      ).save
    end
    
    if !user.nil?
      abort "The default user has already been inserted."
    end
    
    user = Users::Model::User.new(
      :email => 'admin@website.tld', :name => 'Administrator',
      :password => password, :status => 'open'
    ).save
    
    user.user_group_pks = [group.id]
    
    puts "Default administrator account has been created.

Email: admin@website.tld
Passowrd: #{password}

You can login by going to http://domain.tld/admin/users/login/
"
  end
end
