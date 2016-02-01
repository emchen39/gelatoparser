require 'ostruct'
require 'optparse'
require_relative 'operators/logger_operator'

class OptParser


  TIMESTAMP_FORMAT = %w[F T FT E]
  OUTPUT_FORMAT = %w[csv json]

  def self.parse(args)
    options = OpenStruct.new
    options.calculate_elapsed = false
    options.input_files = []
    options.timestamp_format = nil
    options.output_formats = []
    options.new_config = []
    options.config_file = nil
    options.output_location = nil

    opt_parser = OptionParser.new do |opts|

      opts.separator('Required:')

      # required to pass in configuration file unless -n or --new was specified
      opts.on('-c', '--config FILE', 'Supply the configuration files') do |config|
        options.config_file = config
      end

      opts.separator('Optional:')
      # these changes will not alter the content of the configuration file directly

      opts.on('-e', '--get-elapsed FORMAT', TIMESTAMP_FORMAT, 'Supply the format of timestamp, i.e. F, T, FT, E') do |time_format|
        options.calculate_elapsed = true
        options.timestamp_format = time_format
      end

      # will override the output path in the configuration file. e.g. -o Users/username/results
      opts.on('-o', '--output PATH', 'Path of folder to which output should be saved') do |out|
        options.output_location = out
      end

      # add an input file to each of the configuration files passed in. This does not support adding
      # only to one specific configuration file.
      opts.on('-i', '--input PATH', 'Path of input file to be included') do |file|
        options.input_files << file
      end

      # add an output format to each of the files to be parsed
      opts.on('-f', '--format FORMAT', OUTPUT_FORMAT, 'Format in which to output the parsed data') do |format|
        options.output_formats << format
      end

      # when specified, the program will create a template configuration file at the given location.
      # The user should manually edit the configuration file and then use it for parsing files
      opts.on('-n', '--new NAME,[PATH]', Array, 'Creates a default configuration file [PATH]/NAME.json. Path defaults to user\'s home directory') do |name_and_path|
        options.new_config = name_and_path
      end

      opts.separator('')

      opts.on_tail('-h', '--help', 'Show this message') do
        puts opts
        exit
      end

    end

    opt_parser.parse!(args)
    validate_options(options)

    options
  end


  # raise an error if neither a configuration file is provided nor a new configuration file is to be generated
  def self.validate_options(options)
    raise ParserExceptions::MissingArgument, LoggerOperator::fatal('Missing configuration file.') if options.config_file.nil? && options.new_config.empty?
  end

end