module DBIExceptions

  class InvalidFile < StandardError; end


  class UnknownFieldName < StandardError; end


  class BadPostgresqlSettings < StandardError; end

  class SHA1Duplicate < StandardError; end

end