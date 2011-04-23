require 'fileutils'

##
# Command that can be used to generate a new application.
#
# @author Yorick Peterse
# @since  0.2.5
# 
command :app do |cmd|

  # Set a few details of the command
  cmd.syntax      = '$ zen app [NAME]'
  cmd.description = 'Creates a new application powered by Zen.'

  cmd.option('-f', TrueClass, 'Overwrites any existing application.')

  # The action to execute when the command is invoked
  cmd.action do |args, opts|
    if args.empty?
      abort 'You need to specify a name for the application.'
    end

    name  = args[0]
    app   = File.join('./', name)
    proto = File.expand_path('../../../../proto/app', __FILE__)
    
    if File.directory?(app) and !opts.f
      abort "The application #{app} alread exists, use -f to overwrite it."
    else
      FileUtils.rm_rf(app)
    end

    # Copy the prototype
    begin
      FileUtils.cp_r(proto, app)
      puts "The application has been generated and saved in #{app}"
    rescue => e
      abort "Failed to generate the application: #{e.message}"
    end
  end

end
