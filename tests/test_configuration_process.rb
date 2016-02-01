require 'test/unit'
require_relative '../lib/parser/configuration'

class TestConfigurationProcess < Test::Unit::TestCase

  def setup
    @cwd = File.dirname(__FILE__)
    @sample_file = File.join(@cwd, 'misc/sample.json')
    # this step already handles the processing step
    @sample_configuration = Configuration.new(@sample_file)
  end
  
  def test_required_variables
    assert_not_nil(@sample_configuration.inputs, '@inputs expected to be not nil')
    assert_not_nil(@sample_configuration.triggers, '@triggers expected to be not nil')
    assert_not_nil(@sample_configuration.outputs_formats, '@output expected to be not nil')
  end
  
  def test_input_type
    assert(@sample_configuration.inputs.is_a?(String) || @sample_configuration.inputs.is_a?(Array),
           '@inputs must be a String or an Array')
  end
  
  def test_metadata_type
    assert(@sample_configuration.metadata.is_a?(Hash) || @sample_configuration.metadata.nil?,
           '@metadata must either be a Hash or Nil')
  end
  
  def test_identifiers_type
    assert(@sample_configuration.identifiers.is_a?(Hash) || @sample_configuration.identifiers.nil?,
           '@identifiers must either be a Hash or Nil')
  end
  
  def test_triggers_type
    assert(@sample_configuration.triggers.is_a?(Hash), '@triggers must be a Hash')
  end
  
  def test_output_type
    assert(@sample_configuration.outputs_formats.is_a?(Array) || @sample_configuration.outputs_formats.is_a?(String),
           '@outputs_format must be an Array or a String')
    assert(@sample_configuration.outputs_location.is_a?(String) || @sample_configuration.outputs_location.nil?,
           '@outputs_location must be a String or a Nil')
  end

  def test_inputs
    inputs = %w(/Users/emmac/PerfLab/results/ws/results/harmony_run1/scale_get_merged_defects_for_project_scope.log
        /Users/emmac/PerfLab/results/ws/results/harmony_run2/scale_get_merged_defects_for_project_scope.log)

    assert_equal(inputs, @sample_configuration.inputs, 'inputs do not match expected values')
  end

  def test_metadata
    pattern_test_name = Pattern.new('Concurrent Commit')
    pattern_date_ran = Pattern.new(/Start Time: (.+) UTC/, 1)
    pattern_machines = Pattern.new('lin5/load5')

    metadata = {'test name' => [pattern_test_name],
        'date ran' => [pattern_date_ran],
        'machines' => [pattern_machines]
    }

    assert_equal(metadata, @sample_configuration.metadata, 'metadata do not match expected values')
  end

  def test_identifiers
    pattern_scope = Pattern.new(/Starting getMergedDefectsForProjectScope with (.+)\.\.\./, 1)
    pattern_page_size = Pattern.new(/with page size of : ([[:digit:]]+)/, 1)
    pattern_count = Pattern.new(/count=(.+)\]/, 1)

    identifiers = { 'scope' => [pattern_scope],
                    'page size' => [pattern_page_size],
                    'count' => [pattern_count] }

    assert_equal(identifiers, @sample_configuration.identifiers, 'identifiers do not match expected values')
  end

  def test_triggers
    pattern_duration = Pattern.new(/DURATION- +\[took (.+?)ms/, 1)

    triggers = {
        'duration' => [pattern_duration]
    }

    assert_equal(triggers, @sample_configuration.triggers, 'triggers do not match expected values')
  end

  def test_output_formats
    output_formats = %w(csv json)
    assert_equal(output_formats, @sample_configuration.outputs_formats, 'output formats do not match expected values')
  end
  
end