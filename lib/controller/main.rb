require 'optparse'
require_relative '../../lib/controller/pg_settings'
require_relative '../../lib/controller/opt_parser'
require_relative '../../lib/controller/pg_handler'

class Main

  attr_accessor :pg_options, :conn
  ACTION = ARGV[0].nil? ? nil : ARGV[0].downcase


  def parse_args
    OptParser.general_parse(ARGV)
  end

  def pg_connect
    begin
      PgSettings.get_connection
    rescue => e
      puts e.message
      exit(1)
    end
  end

  def help
    puts 'commands: setup|showpg|inject-raw|create-view --help'
  end

  def command
    begin
    case ACTION
      when 'setpg'
        @options = OptParser.pg_parse(ARGV)
        PgSettings.set_connection(@options)
      when 'showpg'
        PgSettings.show_pg
      when 'inject-raw'
        @options = OptParser.ir_parse(ARGV)
        @conn = pg_connect
        PgHandler.inject_raw(@conn, @options)
      else
        help
    end

		@conn.close
    rescue => e
      puts e.message
      exit(1)
    end

  end

end
