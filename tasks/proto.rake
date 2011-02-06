
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
end
