require 'yaml'
require 'pg'
require_relative '../../lib/controller/exceptions/dbi_exceptions'

module PgSettings

  @path = File.join(File.dirname(__FILE__), 'var/settings.yml')


  # establish connection to the postgresql database
  def self.get_connection(config=@path)
    settings = YAML::load_file(config)

    raise DBIExceptions::BadPostgresqlSettings,  LoggerOperator::fatal('PostgreSQL connection settings.yml not set.') unless settings['pg_set']
    set = {:host => settings['pg_host'],
           :port => settings['pg_port'],
           :user => settings['pg_user'],
           :password => settings['pg_password'],
           :dbname => settings['pg_dbname']}

    begin
      PG::Connection.new(set)
    rescue => e
      puts e.message
      puts 'Make sure PostgreSQL is configured correctly.'
      exit(1)
    end
  end


  # set the connection settings file
  def self.set_connection(options, config=@path)
    settings = YAML::load_file(config)

    settings['pg_host'] = options[:host] unless options[:host].nil?
    settings['pg_port'] = options[:port] unless options[:port].nil?
    settings['pg_user'] = options[:user] unless options[:user].nil?
    settings['pg_password'] = options[:password].nil? ? '' : options[:password]
    settings['pg_dbname'] = options[:dbname] unless options[:dbname].nil?
    settings['pg_set'] = settings.has_value?(nil) ? false : true

    File.open(config, 'w') {|f| f.write(settings.to_yaml)}
    show_pg
  end


  # display connection settings
  def self.show_pg(config=@path)
    settings = YAML::load_file(config)

    puts "Current Postgresql Connection Settings:\n"
    puts "host      : #{settings['pg_host']}"
    puts "user      : #{settings['pg_user']}"
    puts "password  : #{settings['pg_password']}"
    puts "database  : #{settings['pg_dbname']}"
    puts "port      : #{settings['pg_port']}"
  end

end