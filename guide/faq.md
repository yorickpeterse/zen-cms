# @title Frequently Asked Questions
# Frequently Asked Questions

## When starting I get the warning "Failed to migrate the settings..."

This warning appears when Zen failed to insert/update the various settings
stored in the database. In almost all cases this warning is caused because the
settings table doesn't exist. This issue can be solved by simply running the
following command:

    $ rake db:migrate

## I get errors such as "no such table: X"

Similar to the issue above this error is caused by missing database tables and
again this can be fixed by simply migrating the database:

    $ rake db:migrate

## Users are randomly logged out and settings are lost

This happens when you're running your Zen application using a Rack server that
uses multiple processes (e.g. Unicorn) in combination with memory based caches
for the session and settings data. The easiest fix for this problem is to simply
use an external cache for the settings and session data.

It's recommended to either use Memcached using ``Ramaze::Cache::MemCache`` or
Redis using ``Ramaze::Cache::Redis``. These caches can be set as following in
``config/config.rb``:

    Ramaze::Cache.options.session  = Ramaze::Cache::MemCache
    Ramaze::Cache.options.settings = Ramaze::Cache::MemCache

For Redis you'd do the following:

    Ramaze::Cache.options.session  = Ramaze::Cache::Redis
    Ramaze::Cache.options.settings = Ramaze::Cache::Redis

## Can I use Zen for non open source projects?

Yes. Zen is licensed under the MIT license which is a very flexible license. As
long as you keep the license intact and include it in your projects that use Zen
you're free to do whatever you like. For more information see the "LICENSE"
file, you can find this file in the Git repository as well as in the "File list"
dropdown at the top right of this page.

## Can I contact you personally via Email or IRC?

Yes, as long as any messages are written in decent English so that I can
understand them you're more than welcome to contact me directly.
