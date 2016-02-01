class Flavour

  attr_accessor :identifiers, :triggers, :name, :identifier_list, :trigger_list

  def initialize(flavour_name)
    @name = flavour_name
    @identifiers = Hash.new
    @triggers = Hash.new
    @identifier_list = Array.new
    @trigger_list = Array.new
  end


  def set_identifiers(hash)
    if hash.respond_to?(:each)
      hash.each do |k, v|
        @identifiers[k] = RegexpOperator.get_all_patterns(v, true)
      end
    end

    @identifier_list = @identifiers.keys
  end


  def set_triggers(hash)
    if hash.respond_to?(:each)
      hash.each do |k, v|
        @triggers[k] = RegexpOperator.get_all_patterns(v, true)
      end
    end

    @trigger_list = @triggers.keys
  end
end