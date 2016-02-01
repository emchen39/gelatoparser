require 'optparse'
require_relative 'opt_parser'
require_relative 'configuration'
require_relative 'file_parser'
require_relative 'elapsed_time_calculator'
require_relative 'operators/output_operator'
require_relative 'operators/logger_operator'
require_relative 'exceptions/parser_exceptions'


class Main

  attr_accessor :options

  # parses ARGV and stores options
  def setup
    begin
      @options = OptParser.parse(ARGV)
    rescue ParserExceptions::MissingArgument
      exit(1)
    end

  end


  # program execution
  def run
    setup

    # if user passed in option to generate default configuration files, then
    # all other options passed in should be ignored. Program ends after the default
    # configuration files are generated.
    unless @options.new_config.empty?
      add_new_config
      exit(0)
    end

    # create the object where input files are stored and configurations are stored
    parser = FileParser.new(@options)
    parser.parse_all_files
    parser.output_all_files
  end


  # creates a new configuration file
  def add_new_config
    name = @options.new_config[0]
    path = @options.new_config.length == 2 ? @options.new_config[1] : nil
    # makes a call to generate a default configuration file
    new_file = OutputOperator.new_default_configuration(name, path)
    LoggerOperator::info("A template configuration file was created at #{new_file}.")
    exit
  end
end
