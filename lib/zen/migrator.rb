module Zen
  ##
  # Small wrapper around Sequel::Migrator to fix various issues and make it a
  # bit easier to log data.
  #
  # @since 07-01-2012
  #
  module Migrator
    ##
    # Runs a set of migrations and logs the actions.
    #
    # @since 07-01-2012
    # @see   Sequel::Migrator.run
    # @param [String] name The name of the package/theme/etc to migrate.
    # @param [String] dir The directory containing the migrations.
    # @param [String] table The name of the table to store the migrations in.
    # @param [NilClass|Fixnum] target The target version to migrate to.
    #
    def self.run(name, dir, table, target = nil)
      # Sequel 3.31.0 changed the way altering tables works, this causes some
      # annoying issues to occur when using foreign keys in SQLite3. This can be
      # fixed by turning off foreign keys while running the migrations.
      #
      # See this pastie for an example of this issue: http://pastie.org/3140474
      if Zen.database.adapter_scheme == :sqlite
        Ramaze::Log.debug('Turning off foreign keys for SQLite3')
        Zen.database.execute('PRAGMA foreign_keys = OFF;')
      end

      Sequel::Migrator.run(
        Zen.database,
        dir,
        :table  => table,
        :target => target
      )

      if target.nil?
        Ramaze::Log.info("Migrated #{name} to the latest version")
      else
        Ramaze::Log.info("Migrated #{name} to version #{target}")
      end

      if target == 0
        Ramaze::Log.info("Dropping table #{table}")
        Zen.database.drop_table(table)
      end

      if Zen.database.adapter_scheme == :sqlite
        Ramaze::Log.debug('Turning foreign keys on again')
        Zen.database.execute('PRAGMA foreign_keys = ON;')
      end
    end
  end # Migrator
end # Zen
