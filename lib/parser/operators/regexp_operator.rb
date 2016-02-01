require_relative 'logger_operator'

module RegexpOperator

  # the format of a valid gparse regex expression. e.g. regexp(1)=pattern([[:digit:]]+)
  @regexp_indicator = /\Aregexp\(([[:digit:]]*)\)/

  def self.is_regexp?(string)
    string =~ @regexp_indicator ? true : false
  end


  # if must_be_regex is set to true, then the string must be a valid gparse regex expression or the program will
  # throw an error. otherwise, parse the string into 2 components if it is a gparse regex expression:
  #   1. the regexp
  #   2. the backreference number
  # if the string is not a gparse regex expression, then simply return the string as it is.
  def self.get_regexp_or_string(string, must_be_regex = false)
    all = Array.new

    expressions = split_expressions(string)
    expressions.each do |exp|
      if is_regexp?(exp)
        start = exp.index('=') + 1
        str = exp[start..-1]
        result = Regexp.new(str)

        find_back_reference = @regexp_indicator.match(exp)[1]
        if find_back_reference.empty?
          backreference = 0
        else
          backreference = find_back_reference.to_i
        end

        # create a hash to store the pattern and the backreference number
        all << Pattern.new(result, backreference)
      else
        if must_be_regex
          raise ParserExceptions::MustBeRegexpError, LoggerOperator::error("The expression \"#{string}\" must be a regular expression declared with prefix \"regexp(<INT>)=\".")
        end
        all << Pattern.new(exp)
      end
    end

    all
  end


  # return an array of patterns
  def self.get_all_patterns(string, must_be_regex = false)

    begin
      all_patterns = get_regexp_or_string(string, must_be_regex)
    rescue ParserExceptions::MustBeRegexpError
      exit(1)
    end

    all_patterns
  end


  # multiple patterns are supported to match a metric, first split the string by the separator |or|
  def self.split_expressions(string)
    string.split('|or|')
  end

end
