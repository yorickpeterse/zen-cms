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
end
