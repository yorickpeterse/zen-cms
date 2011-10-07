namespace :proto do
  desc 'Creates a new migration'
  task :migration, :directory, :name do |task, args|
    require File.expand_path('../../../zen', __FILE__)
    require 'fileutils'

    # Validate the input
    if !args[:directory]
      abort 'You need to specify a directory for the migration.'
    end

    if !args[:name]
      abort 'You need to specify a name for the migration.'
    end

    if !File.directory?(args[:directory])
      abort "The directory #{args[:directory]} doesn't exist."
    end

    proto_path = File.expand_path('../../../../proto/migration.rb', __FILE__)
    new_path   = File.join(args[:directory], "#{Time.new.to_i}_#{args[:name]}.rb")

    # Copy the prototype to the location
    begin
      FileUtils.cp(proto_path, new_path)
      puts "Migration saved in #{new_path}"
    rescue => e
      puts "Failed to create the migration: #{e.message}"
    end
  end
end
