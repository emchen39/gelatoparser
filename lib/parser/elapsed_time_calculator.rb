require 'date'
require 'tempfile'
require 'fileutils'
require 'pp'
require_relative 'exceptions/parser_exceptions'
require_relative 'operators/logger_operator'
require_relative 'operators/file_operator'


class ElapsedTimeCalculator

  # The logic in this class depends on that the timestamps in the files follow the specific format YY-MM-DD HH:MM:SS
  # and that timestamps or epoch appears at the beginning of each line

  attr_accessor :source, :format, :pattern, :epoch, :elapsed

  def initialize(lines, format_string)
    set_timestamp_format(format_string)
    set_timestamp_pattern(format_string)
    set_source(lines)
  end


  def set_source(lines)
    @source = lines
  end


  def set_timestamp_pattern(format_string)
    @pattern_value = timestamp_format_to_pattern(format_string)
  end


  def set_timestamp_format(format_string)
    @format = to_timestamp_format(format_string)
  end


  def convert_to_epoch(string)
    return nil if string.nil?
    time = DateTime.strptime(string, @format).to_time
    time.to_i
  end


  def get_elapsed
    begin
      append_epoch
      append_elapsed
    rescue ParserExceptions::TimestampFormatMismatch
      exit(1)
    end
  end


  def append_epoch
    @epoch = Array.new
    @source.each do |line|
      if @pattern_value.match(line)
        time =  @pattern_value.match(line)[0]
        epoch = @format ? convert_to_epoch(time) : time.to_i
        @epoch << {text:line, epoch:epoch}
      end
    end
    @epoch
  end


  def append_elapsed
    @elapsed = Array.new

    epoch = append_epoch


    # return the source as it is if no epoch was matched
    return @source if epoch.nil?

    epoch.each_index do |index|
      unless index >= @epoch.length-1
        next_index = index+1

        current_epoch = epoch[index][:epoch]
        next_epoch = epoch[next_index][:epoch]
        elapsed = next_epoch - current_epoch

        current_line = epoch[index][:text]
        @elapsed << "[#{elapsed} elapsed] #{current_line}"
      end
    end
    @elapsed
  end


  def timestamp_format_to_pattern(format_string)
    str = format_string.downcase
    case str
      when 'f'
        /\A\d{2}-\d{2}-\d{2}/
      when 't'
        /\A\d{2}:\d{2}:\d{2}/
      when 'ft'
        /\A\d{2}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/
      when 'e'
        /\A\d+/
      else
        raise ParserExceptions::InvalidArgument, LoggerOperator::error('Invalid timestamp format.')
    end
  end


  def to_timestamp_format(format_string)
    str = format_string.downcase
    case str
      when 'f'
        '%F'
      when 't'
        '%T'
      when 'ft'
        '%F %T'
      when 'e'
        nil
      else
        raise ParserExceptions::InvalidArgument, LoggerOperator::error('Invalid timestamp format.')
    end
  end


  def get_elapsed_pattern
    'regexp(1)=\A\[(\d+) elapsed\]'
  end

end
