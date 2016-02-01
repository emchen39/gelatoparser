class Pattern

  # Each flavour contains a pattern or and a backreference

  attr_accessor :pattern_value, :backreference

  def initialize(pattern, backreference=nil)
    @pattern_value = pattern
    @backreference = backreference
  end

  def is_string?
    @pattern_value.is_a?(String) ? true : false
  end

  def is_regexp?
    @pattern_value.is_a?(Regexp) ? true : false
  end

  def get_match(str)
    if is_string?
      @pattern_value
    else
      match_string = @pattern_value.match(str)
      if match_string
        match_string[backreference]
      end
    end
  end

  def ==(other)
   @pattern_value == other.pattern_value && @backreference == other.backreference ? true : false
  end

end