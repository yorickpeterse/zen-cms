namespace :db do
  desc 'Migrates the entire database'
  task :migrate do
    require File.expand_path('../../../zen', __FILE__)

    if Zen::Package::REGISTERED.empty?
      abort "No packages have been registered."
    end

    # Get the details required to run a migration
    Zen::Package::REGISTERED.each do |name, pkg|
      # Get the migration directory
      if pkg.respond_to?(:migrations) and !pkg.migrations.nil?
        dir = pkg.migrations
      else
        Ramaze::Log.info(
          "Skipping #{pkg.title} as it has no migrations directory"
        )
        next
      end

      if !File.directory?(dir)
        abort "The migration directory #{dir} doesn't exist."
      end

      table = 'migrations_package_' + pkg.name.to_s

      Zen::Migrator.run(pkg.name, dir, table)
    end
  end

  desc 'Deletes the entire database'
  task :delete do
    require File.expand_path('../../../zen', __FILE__)

    if Zen::Package::REGISTERED.empty?
      abort "No packages have been registered."
    end

    packages = Zen::Package::REGISTERED.map { |name, pkg| [name, pkg] }.reverse

    # Get the details required to run a migration
    packages.each do |name, pkg|
      # Get the migration directory
      if pkg.respond_to?(:migrations) and !pkg.migrations.nil?
        dir = pkg.migrations
      else
        Ramaze::Log.info(
          "Skipping #{pkg.title} as it has no migrations directory"
        )
        next
      end

      if !File.directory?(dir)
        abort "The migration directory #{dir} doesn't exist."
      end

      table = 'migrations_package_' + pkg.name.to_s

      Zen::Migrator.run(pkg.name, dir, table, 0)
    end
  end

  desc 'Creates a default admin user'
  task :user do
    require File.expand_path('../../../zen', __FILE__)

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

    unless user.nil?
      abort "The default user has already been inserted."
    end

    user = Users::Model::User.create(
      :email    => 'admin@website.tld',
      :name     => 'Administrator',
      :password => password
    )

    user.activate!
    user.user_group_pks = [group.id]

    puts "Default administrator account has been created.

Email: admin@website.tld
Passowrd: #{password}

You can login by going to http://domain.tld/admin/users/login/"
  end
end
