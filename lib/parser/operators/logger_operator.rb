require 'logger'

module LoggerOperator

  @logger = Logger.new(STDOUT)
  @logger.level = Logger::DEBUG
  @original_formatter = Logger::Formatter.new
  @logger.formatter = proc { |severity, datetime, progname, msg|
    "%-10s #{msg}\n" % "[#{severity}] --"
  }

  def self.warn(msg)
    @logger.warn(msg)
  end

  def self.error(msg)
    @logger.error(msg)
  end

  def self.fatal(msg)
    @logger.fatal(msg)
  end

  def self.info(msg)
    @logger.info(msg)
  end

  def self.debug(msg)
    @logger.debug(msg)
  end

end