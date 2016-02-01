class ParserExceptions
  
  class JSONConfigurationError < StandardError; end


  class UnknownConfigurationOption < StandardError; end


  class ObjectNotAcceptedError < StandardError; end


  class MissingConfigurationField < StandardError; end


  class MustBeRegexpError < StandardError; end


  class NilParameter < StandardError; end


  class InvalidArgument < StandardError; end


  class MissingArgument < StandardError; end


  class TimestampFormatMismatch < StandardError; end


  class NoDataParsed < StandardError; end
end