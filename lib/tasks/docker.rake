require 'net/ping'

namespace :docker do
  def are_all_migrations_up?
    ActiveRecord::Migrator.migrations_status(["."]).
      map(&:first).all?{ |status| status == "up" }
  end

  task :pause_for_db do
    host, port =ENV["DATABASE_URL"].split(/@/).last.split(/\//).first.split(/:/)

    puts "Pinging: #{host} @ #{port}"
    ping = Net::Ping::TCP.new(host)
    ping.port = port.to_i

    t = Thread.new { sleep(30); Kernel.exit(false) }
    while (!ping.ping?) do ; end
    t.kill
  end

  task :create_postgres_extensions  do
    conn = ActiveRecord::Base.connection
    conn.execute( "create extension hstore;") rescue nil
    conn.execute( "create extension plpgsql;") rescue nil
  end

  task :if_db_not_migrated do
    begin
      exit(!are_all_migrations_up? || FigoSupportedBank.count == 0)
    rescue
      exit(true)
    end
  end

  task :if_db_is_migrated do
    begin
      exit(are_all_migrations_up?)
    rescue
      exit(false)
    end
  end
end
