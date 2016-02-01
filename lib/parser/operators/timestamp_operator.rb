class TimestampOperator

  def self.timestamp_format_to_pattern(string)
    str = string.downcase
    case str
      when 'f'
        /\A\d{2}-\d{2}-\d{2}/
      when 't'
        /\A\d{2}:\d{2}:\d{2}/
      when 'ft'
        /\A\d{2}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/
    end
  end


  def self.to_timestamp_format(string)
    str = string.downcase
    case str
      when 'f'
        '%F'
      when 't'
        '%T'
      when 'ft'
        '%F %T'
    end
  end

end