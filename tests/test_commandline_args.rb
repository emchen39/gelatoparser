require 'test/unit'
require_relative '../lib/parser/configuration'
require_relative '../lib/parser/main'

class TestCommandlineArgs < Test::Unit::TestCase

  def setup
    cwd = InputFile.dirname(__FILE__)
    @configuration = InputFile.join(cwd, 'misc/sample.json')
    ARGV.clear
    ARGV.push('--metadata', 'metadata1, load1')
    ARGV.push('--output', '/Users/emmac/testdir')
    ARGV.push('--input', '/Users/emmac/file_that_doesnt_exist')
    ARGV.push('--identifier', 'identifier1, regexp(1)=some pattern (.+) that does not work')
    ARGV.push('--trigger', 'trigger1, regexp(1)=some pattern (.+) that does not work')
    ARGV.push('--config', @configuration)

    @main = Main.new
    @main.setup
    @gelato = @main.create_instance(@configuration)
  end

  def test_output_override
    assert_equal('/Users/emmac/testdir', @gelato.configuration.outputs_location, 'Output location not overridden.')
  end

  def test_add_input
    assert(@gelato.configuration.inputs.include?('/Users/emmac/file_that_doesnt_exist'), 'Input file not added')
  end


  def test_add_metadata
    assert(@gelato.configuration.metadata.keys.include?('metadata1'), 'Metadata pattern key not added')
    assert(@gelato.configuration.metadata.values.include?([Pattern.new('load1')]), 'Metadata pattern value not added')
  end


  def test_add_identifier
    assert(@gelato.configuration.identifiers.keys.include?('identifier1'), 'Identifier pattern key not added')
    assert_equal([Pattern.new(/some pattern (.+) that does not work/, 1)],
                 @gelato.configuration.identifiers['identifier1'],
                 'Identifier pattern value not added')
  end


  def test_add_trigger
    assert(@gelato.configuration.triggers.keys.include?('trigger1'), 'Trigger pattern key not added')
    assert_equal([Pattern.new(/some pattern (.+) that does not work/, 1)],
                 @gelato.configuration.triggers['trigger1'],
                 'Trigger pattern value not added')
  end


  def teardown
    ARGV.clear
  end
end