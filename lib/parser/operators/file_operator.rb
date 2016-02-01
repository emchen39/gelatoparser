require_relative '../exceptions/parser_exceptions'
require_relative '../pattern'

module FileOperator
  # handles reading and validation methods for inputs


  def self.read(input_file)
    unless File.exist?(input_file) and File.readable?(input_file)
      raise IOError, LoggerOperator::fatal("Input file #{input_file} does not exist or is not readable")
    end

    File.read(input_file)

  end


  def self.readlines(input_file)
    unless File.exist?(input_file) and File.readable?(input_file)
      raise IOError, LoggerOperator::fatal("Input file #{input_file} does not exist or is not readable")
    end

    File.readlines(input_file)
  end

end