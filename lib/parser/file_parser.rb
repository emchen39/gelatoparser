require 'rubygems'
require 'json'
require 'date'
require_relative 'configuration'
require_relative 'input_file'
require_relative 'operators/output_operator'

class FileParser
  # this is the main class where the highest functions of FileParser are defined
  # a file instance is created for each input file. Files are parsed one by one

  attr_accessor :configuration, :file_instances

  def initialize(options)
    @configuration = Configuration.new(options)
    @file_instances = Array.new
    make_instances

    if options.calculate_elapsed
      @file_instances.each do |file_instance|
        elapsed_calculator = ElapsedTimeCalculator.new(file_instance.file_lines, options.timestamp_format)
        file_instance.file_lines = elapsed_calculator.get_elapsed
      end
    end
  end


  def make_instances
    @configuration.input_files.each do |file|
      file = InputFile.new(file, @configuration.flavours)
      @file_instances << file
    end
  end


  def parse_file(file)
    metadata_list = @configuration.metadata.keys

    file.file_lines.each do |line|
      metadata_list.each do |name|
        pattern_list = @configuration.metadata[name]
        matched = false
        pattern_list.each do |pattern|
          data = pattern.get_match(line)
          if data
            file.metadata_store[name] = data
            matched = true
          end
        end

        if matched
          metadata_list.delete(name)
        end
      end
    end

    # parse each flavour
    file.file_lines.each do |line|
      @configuration.flavours.each do |flavour_name, flavour|
        # parse identifiers
        flavour.identifier_list.each do |identifier|
          pattern_list = flavour.identifiers[identifier]
          pattern_list.each do |pattern|
            data = pattern.get_match(line)
            if data
              file.data_store[flavour_name].set_identifier_value(identifier, data)
            end
          end
        end

        # parse triggers
        flavour.trigger_list.each do |trigger|
          pattern_list = flavour.triggers[trigger]
          pattern_list.each do |pattern|
            data = pattern.get_match(line)
            if data
              file.data_store[flavour_name].set_trigger_value(trigger, data)
            end
          end
        end
      end
    end
  end


  def output_file(file)
    epoch = DateTime.now.strftime('%Q')
		
		file.get_flavour_list.each do |flavour_name|
			if file.is_flavour_empty?(flavour_name) then
				LoggerOperator.warn("No data parsed for flavour: '#{flavour_name}' from file: '#{file.filename}', perhaps use a different configuration file?")
			else
	 			@configuration.output_formats.each do |format|
        	OutputOperator.output(format, @configuration.output_location, file, flavour_name, epoch)
				end
			end
    end
  end


  def parse_all_files
    file_instances.each do |file|
      parse_file(file)
    end
  end


  def output_all_files
    file_instances.each do |file|
      output_file(file)
    end
  end


end
