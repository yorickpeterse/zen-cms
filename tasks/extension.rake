Sequel.extension :migration

namespace :extension do
  
  desc "List all loaded extensions and their details"
  task :list do
    Zen::Extension.extensions.each do |ident, ext|
      puts "Name: #{ext.name}"
      puts "Author: #{ext.author}"
      puts "Identifier: #{ext.identifier}"
      puts "--------------"
      puts ext.about + "\n\n"
    end
  end
  
  desc "Migrates a given extension to a certain version number"
  task :migrate, :version do |task, args|
    exts    = []
    version = args[:version]
    
    if !version.nil?
      version = version.to_i
    end
    
    if Zen::Extension.extensions.nil? or Zen::Extension.extensions.empty?
      abort "No extensions have been loaded. Be sure to add them to config/requires.rb"
    end
    
    Zen::Extension.extensions.each do |ident, ext|
      exts.push(ext)
    end
    
    puts "Loaded extensions:"
    exts.each_with_index do |ext, index|
      puts "[#{index}] " + ext.name
    end
    
    # Get the index
    print "Extension number: "
    index = STDIN.gets.strip.to_i
  
    if !exts[index]
      abort "The specified extension does not exist"
    end
    
    install_ext = exts[index]
    
    puts "Migrating..."
    
    dir   = install_ext.directory + '/../../migrations'
    table = install_ext.identifier.gsub('.', '_').to_sym
      
    if File.directory?(dir)
      Zen::Database.handle.transaction do
        Sequel::Migrator.run Zen::Database.handle, dir, :table => table, :target => version
        
        if version == 0
          # Remove the migrations table
          Zen::Database.handle.drop_table table
        end
      end
    end
  end

end
