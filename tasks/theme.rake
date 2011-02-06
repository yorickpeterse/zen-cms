namespace :theme do
  
  desc "List all loaded themes"
  task :list do
    Zen::Package.themes.each do |ident, ext|
      puts "Name: #{ext.name}"
      puts "Author: #{ext.author}"
      puts "Identifier: #{ext.identifier}"
      puts "--------------"
      puts ext.about + "\n\n"
    end
  end
  
  desc "Migrate an installed theme to the specified version"
  task :migrate, :version do |task, args|
    themes = []
    
    if !args[:version].nil?
      version = args[:version].to_i
    else
      version = nil
    end
    
    if Zen::Package.themes.nil? or Zen::Package.themes.empty?
      abort "No themes have been loaded. Be sure to add them to config/requires.rb"
    end
    
    Zen::Package.themes.each do |ident, t|
      themes.push(t)
    end
    
    puts "Loaded themes:"
    themes.each_with_index do |t, index|
      puts "[#{index}] " + t.name
    end
    
    # Get the index
    print "Theme number: "
    index = STDIN.gets.strip.to_i
  
    if !themes[index]
      abort "The specified theme does not exist"
    end
    
    install_theme = themes[index]
    
    puts "Migrating..."
    
    dir   = install_theme.directory + '/../../migrations'
    table = install_theme.identifier.gsub('.', '_').to_sym
      
    if File.directory?(dir)
      Zen::Database.handle.transaction do
        Sequel::Migrator.run(Zen::Database.handle, dir, :table => table, :target => version)
        
        if version == 0
          # Remove the migrations table
          Zen::Database.handle.drop_table table
        end
      end
    end
  end
end
