require 'ostruct'
require 'optparse'

class OptParser
  # parses options from commandline

  def self.general_parse(args)
    options = OpenStruct.new

    parser = OptionParser.new do |opts|
      opts.on('--help', 'Show this message') do
        puts opts
        exit
      end
    end

    parser.parse!(args)
    options
  end

  def self.pg_parse(args)
    options = OpenStruct.new

    parser = OptionParser.new do |opts|

      opts.separator('Setting the postgreSQL connection:')

      opts.on('-h', '--host HOST', 'PostgreSQL server') do |server|
        options[:host] = server
      end

      opts.on('-P', '--Port NUMBER ', 'PostgreSQL port') do |port|
        options[:port] = port
      end

      opts.on('-u', '--user USERNAME', 'PostgreSQL username') do |user|
        options[:user] = user
      end

      opts.on('-p', '--password PASSWORD', 'PostgreSQL password') do |pw|
        options[:password] = pw
      end

      opts.on('-d', '--dbname DATABASE', 'PostgreSQL database name') do |db|
        options[:dbname] = db
      end

      opts.on_tail('--help', 'Show this message') do
        puts opts
        exit
      end

    end

    parser.parse!(args)
    options
  end


  def self.ir_parse(args)
    options = OpenStruct.new
    options[:files] = Array.new
    options[:keys] = Array.new

    parser = OptionParser.new do |opts|

      opts.separator('Commands for injecting raw data')

      opts.on('-f', '--file FILE1,FILE2,...', Array, 'Paths of json files to store') do |files|
        options[:files] += files
      end

      opts.on('-n', '--name KEY1,KEY2,...', Array, 'Keys from json files to get the table name from') do |keys|
        options[:keys] += keys
      end

      opts.on_tail('--help', 'Show this message') do
        puts opts
        exit
      end

    end

    parser.parse!(args)
    options
  end
end

