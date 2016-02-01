require 'rubygems'
require 'json'
require_relative 'operators/file_operator'
require_relative 'operators/regexp_operator'
require_relative 'operators/logger_operator'
require_relative 'exceptions/parser_exceptions'
require_relative 'flavour'


class Configuration

  attr_accessor :config_filename, :input_files, :metadata, :flavours, :output_formats, :output_location, :config_content

  # initializes an object
  def initialize(options)
    @config_content = process_json(options.config_file)
    @config_filename = File.basename(options.config_file, '.json')
    @input_files = Array.new
    @metadata = Hash.new
    @flavours = Hash.new
    @output_formats = Array.new

    process_configurations(options)
    begin
      validate_configurations
    rescue ParserExceptions::MissingConfigurationField => e
      print(e)
      exit(1)
    end

  end

  # reads the configuration file and parse it into JSON format
  def process_json(file_path)
    file = FileOperator.read(file_path)

    begin
      @config_content = JSON.parse(file)
    rescue JSON::ParserError
      LoggerOperator::fatal("Please make sure that the configuration file is valid JSON.")
      exit(1)
    end

  end


  # collect all configurations
  def process_configurations(options)
    process_input_files(options)
    process_metadata
    process_flavours
    process_output_formats(options)
    process_output_location(options)
  end


  def process_input_files(options)
    # processes the inputs information from configuration file. Inputs
    # allow two types of entry, arrays and strings and stores them into @inputs

    input_files = Array.new

    if @config_content['input'].respond_to?(:each)
      input_files = @config_content['input'] + options.input_files
    elsif @config_content['input'].is_a?(String)
      input_files = options.input_files + [@config_content['input']]
    else
      input_files = options.input_files
    end

    input_files.each do |file|
      add_input(file)
    end
  end


  def process_flavours
    #process configurations of each flavour
    if @config_content['flavours'].respond_to?(:each)
      @config_content['flavours'].keys.each do |flavour|
        flv = Flavour.new(flavour)
        flv.set_identifiers(@config_content['flavours'][flavour]['identifiers'])
        flv.set_triggers(@config_content['flavours'][flavour]['triggers'])
        @flavours[flv.name] = flv
      end
    end
  end

  def process_metadata
    if @config_content['metadata'].respond_to?(:each)
      @config_content['metadata'].each do |k, v|
        @metadata[k] = RegexpOperator.get_all_patterns(v, false)
      end
    end
  end

  # process the output information from configuration file
  #   current configurable attributes include:
  #   1. outputs location: "location" (this is OPTIONAL, if left unspecified, FileParser will default to
  #      saving output files to the use's home directory)
  #   2. outputs formats: "formats" (this is OPTIONAL, if left unspecified, output both csv and json files)

  def process_output_formats(options)

    if options.output_formats.empty?
      formats = @config_content['format']
      if formats.respond_to?(:each)
        formats.each do |out|
          add_output_format(out)
        end
      end
    else
      options.output_formats.each do |out|
        add_output_format(out)
      end
    end

    if @output_formats.empty?
      @output_formats = %w(json csv)
      LoggerOperator.warn('Output file format set to json and csv by default.')
    end
  end


  def process_output_location(options)
    if options.output_location
      @output_location = options.output_location
    elsif @config_content['output']
      @output_location = @config_content['output']
    else
      @output_location = Dir.home
      LoggerOperator.warn('Output location will be defaulted to the user home directory.')
    end
  end


  # determines if the formats inputted by the user is a valid format
  # currently support formats include:
  # 1. csv
  # 2. json
  def is_acceptable_output?(string)
    string.downcase.eql?('csv') || string.downcase.eql?('json') ? true : false
  end


  def add_output_format(out)
    if is_acceptable_output?(out)
      unless @output_formats.include?(out)
        @output_formats << out
      end
    else
      raise ParserExceptions::JSONConfigurationError, LoggerOperator.error("\"#{out}\" is an invalid output type, please specify csv or json format.")
    end
  end

  def add_input(input_file)
    Dir.glob(input_file)
    files = Dir.glob(input_file)
    files.each do |file|
      unless @input_files.include?(file)
        @input_files << file
      end
    end
  end


  def validate_configurations
    if @input_files.empty?
      raise ParserExceptions::MissingConfigurationField, LoggerOperator.fatal("Missing or empty 'input' field")
    end

    if @flavours.empty?
      raise ParserExceptions::MissingConfigurationField, LoggerOperator.fatal("Missing or empty 'flavour' field")
    end

    if @metadata.empty?
      LoggerOperator.warning('No metadata provided')
    end
  end

end
