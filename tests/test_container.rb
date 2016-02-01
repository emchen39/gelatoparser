require 'test/unit'
require_relative '../lib/parser/holder'
require_relative '../lib/parser/container'
require_relative '../lib/parser/configuration'

class TestContainer < Test::Unit::TestCase

  def setup
    @file = 'misc/scale_get_merged_defects_for_project_scope.log'
    @holder = Holder.new
    @cwd = File.dirname(__FILE__)
    @sample_file = File.join(@cwd, 'misc/sample.json')
    # this step already handles the processing step
    @sample_configuration = Configuration.new(@sample_file)
    @test_container = Container.new(@file, @holder, @sample_configuration)
  end


  def test_match_found_and_set
    exp = Pattern.new(/-DURATION- \[took ([[:digit:]]+)ms/, 1)
    name = 'duration'
    line = '-DURATION- [took 2321ms]'

    @test_container.matched_and_set?(line, name, exp)

    assert_equal('2321', @test_container.holder.data_holder['duration'], 'Value in holder was set incorrectly')
  end



end