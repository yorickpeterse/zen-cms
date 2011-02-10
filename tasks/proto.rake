require 'ruby-extensions'
require 'fileutils'

namespace :proto do
  
  desc "Generate a new migration and save it in the specified directory"
  task :migration, :directory do |task, args|
    dir = args[:directory]
    
    # Get the name
    print "Migration name: "
    name = STDIN.gets.strip
    
    # If no directory is specified we'll store the migrations under ./migrations
    if dir.nil? or dir == ''
      if !File.directory?('./migrations')
        abort "No directory specified and ./migrations doesn't exist"
      else  
        dir = './migrations'
        puts "Using ./migrations"
      end
    else  
      puts "Using #{dir}"
    end
    
    # Generate the prototype
    puts "Generating..."
    
    proto = File.open(__DIR__('../proto/migration.rb'), 'r').read
    path  = "#{dir}/#{Time.new.to_i}_#{name}.rb"
    
    begin
      File.open(path, 'w').write(proto)
      puts "Done!"
    rescue => e
      puts "Failed to generate the migration: #{e}"
    end
  end

  desc "Generate a new package prototype"
  task :package, :name do |task, args|
    if args[:name].nil?
      abort "You need to specify an extension name"
    end

    name  = args[:name].strip.downcase.gsub(' ', '_')
    proto = __DIR__('../proto/package')
    klass = name.camel_case
        
    extension_path = "./#{name}"
    
    FileUtils.rm_rf(extension_path)
    
    # Rename all files and folders
    begin
      FileUtils.cp_r(proto, extension_path)
      
      lib_path = "#{extension_path}/lib/#{name}"
      
      # Rename the base file and directory
      FileUtils.mv("#{extension_path}/lib/package"   , lib_path)
      FileUtils.mv("#{extension_path}/lib/package.rb", "#{extension_path}/lib/#{name}.rb")
      
      # ------------------------------------------------
      
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
      abort "Failed to generate the extesion: #{e}"
    end
  end
end
