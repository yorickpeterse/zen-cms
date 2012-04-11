# Task that checks the documentation for spelling errors using Raspell/Aspell.
# This task requires Aspell to be installed along with an English dictionary. On
# Arch Linux these can be installed as following:
#
#     $ sudo pacman -S aspell aspell-en
#
desc 'Search docs for spelling errors'
task :spelling do
  require 'raspell'
  require 'ripper'

  speller = Aspell.new1(
    'lang'        => 'en',
    'personal'    => File.expand_path('../../../../.aspell.en.pws', __FILE__),
    'ignore-case' => 'true'
  )

  base_dir         = File.expand_path('../../../..', __FILE__)
  files            = Dir['lib/zen/**/*.rb']
  exclude_lines    = [/^#\s*@/, /^#\s{2,}/, /^#\s*!\[/, /^#\s*\[/]
  exclude_patterns = [/\d+/, /_+/, /^`/]

  files.each do |file|
    file     = File.expand_path(file)
    relative = file.gsub(/^#{base_dir}\//, '')
    errors   = []
    content  = File.read(file, File.size(file))

    Ripper.lex(content).each do |group|
      next unless group[1] == :on_comment

      skip_line = false

      # Determine whether or not the entire line should be skipped.
      exclude_lines.each do |pattern|
        if group[2] =~ pattern
          skip_line = true
          break
        end
      end

      next if skip_line

      # Extract each word out of the line.
      group[2].gsub(/[\w'-]+/).each do |word|
        skip = false
        word = word.gsub(/^'|'$/, '')

        # Determine if the word should be ignored based on a list of blacklisted
        # patterns.
        exclude_patterns.each do |pattern|
          if word =~ pattern
            skip = true
            break
          end
        end

        # Exclude words that are actually constants (e.g. FalseClass). This
        # isn't very fast but it prevents the requirement of using a few nasty
        # regular expressions.
        unless skip
          lexed = Ripper.lex(word)

          if lexed[0] and lexed[0][1] == :on_const
            skip = true
          end
        end

        next if skip == true

        unless speller.check(word)
          suggested = speller.suggest(word)[0]

          if suggested
            errors << {
              :line       => group[0][0],
              :column     => group[0][1],
              :word       => word,
              :suggestion => suggested
            }
          end
        end
      end
    end

    unless errors.empty?
      puts
      puts relative
      puts

      errors.each do |error|
        puts "  * line ##{error[:line]}, column ##{error[:column]}: " \
          "#{error[:word]}, suggestion: #{error[:suggestion]}"
      end
    end
  end
end
