require 'fileutils'
require __DIR__('../ext/string')

##
# Task group used for creating various prototypes.
#
# @author Yorick Peterse
# @since  0.2.5
#
namespace :proto do

  desc 'Creates a new migration'
  task :migration, :directory, :name do |task, args|
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

  desc 'Creates a new package'
  task :package, :directory, :name do |task, args|
    # Validate the input
    if !args[:name]
      abort 'You need to specify the name of your package.'
    end

    if !args[:directory]
      abort 'You need to specify a directory where the package should be saved.'
    end

    name           = args[:name]
    proto          = File.expand_path('../../../../proto/package', __FILE__)
    klass          = name.camel_case
    extension_path = File.join(args[:directory], name)
    
    FileUtils.rm_rf(extension_path)
    
    # Rename all files and folders
    begin
      FileUtils.cp_r(proto, extension_path)
      
      lib_path = "#{extension_path}/lib/#{name}"
      
      # Rename the base file and directory
      FileUtils.mv("#{extension_path}/lib/package"   , lib_path)
      FileUtils.mv("#{extension_path}/lib/package.rb", "#{extension_path}/lib/#{name}.rb")
      
      controller_filename = klass.snake_case.pluralize
      model_filename      = klass.snake_case.singularize
      
      # Generate the controller
      controller = File.open("#{lib_path}/controller/controllers.rb", 'r').read
      controller.gsub!('CONTROLLER', klass.pluralize)
      controller.gsub!('EXTENSION' , klass.pluralize)
      
      FileUtils.mv("#{lib_path}/controller/controllers.rb", "#{lib_path}/controller/#{controller_filename}.rb")
      File.open("#{lib_path}/controller/#{controller_filename}.rb", 'w').write(controller)

      # Move the view directory
      FileUtils.mv("#{lib_path}/view/admin/package", "#{lib_path}/view/admin/#{controller_filename}")
      
      # Generate the model
      model = File.open("#{lib_path}/model/model.rb", 'r').read
      model.gsub!('MODEL'     , klass.singularize)
      model.gsub!('EXTENSION' , klass.pluralize)
      
      FileUtils.mv("#{lib_path}/model/model.rb", "#{lib_path}/model/#{model_filename}.rb")
      File.open("#{lib_path}/model/#{model_filename}.rb", 'w').write(model)
      
      puts "Done! Don't forget to rename the controllers/models/etc"
    rescue => e
      abort "Failed to generate the package: #{e}"
    end
  end

end
