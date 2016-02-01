require 'test/unit'
require_relative '../lib/parser/operators/regexp_operator'
require_relative '../lib/parser/pattern'

class TestInputStringOrRegexp < Test::Unit::TestCase
  
  def test_is_regexp
    # case 1: string not a proper expression of regexp
    result = RegexpOperator.is_regexp?('this is a sample String that is not a regexp')
    assert(!result, 'incorrect determination of regexp')
    
    # case 2: string is a proper expression of regexp
    result = RegexpOperator.is_regexp?('regexp(1)=this is a regexp')
    assert(result, 'incorrect determination of regexp')
  end
  
  def test_convert_to_regexp
    # case 1: converting a string that contains a regexp expression into a regexp
    string = 'regexp()=[[:digit:]]+blah'
    assert_equal([Pattern.new(/[[:digit:]]+blah/, 0)], RegexpOperator.get_regexp_or_string(string),
                 'incorrect regexp conversion')
    
    # case 2: a string that is not a proper regexp declaration will remain as it is
    string = '[[:digit:]]+incorrect regexp'
    assert_equal([Pattern.new('[[:digit:]]+incorrect regexp')], RegexpOperator.get_regexp_or_string(string),
                 'incorrect regexp conversion')
  end

end