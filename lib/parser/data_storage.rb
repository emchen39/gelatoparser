class DataStorage

  attr_accessor :identifier_holder, :trigger_holder, :storage

  def initialize(flavour)
    @identifier_holder = Hash.new
    @trigger_holder = Hash.new
    @storage = Array.new


   flavour.identifier_list.each do |name|
      @identifier_holder[name] = nil
    end

    flavour.trigger_list.each do |name|
      @trigger_holder[name] = nil
    end
  end


  # returns an hash of current data
  def get_current_data
    @identifier_holder.merge(@trigger_holder)
  end


  def insert_current_data
    @storage << get_current_data
  end


  def get_storage
    @storage
  end


  def is_trigger_storage_empty?
    @trigger_holder.values.empty? ? true : false
  end


  def set_identifier_value(name, value)
    @identifier_holder[name] = value
  end


  # make each trigger value nil first then set the trigger value
  def set_trigger_value(name, value)
    @trigger_holder.each_key do |key|
      @trigger_holder[key] = nil
    end

    @trigger_holder[name] = value
    insert_current_data
  end


  def empty?
    @storage.empty? ? true : false
  end


  # add a hash to each element in @storage
  def add_to_each_line(hash)
    @storage.each_index do |i|
      @storage[i] =  hash.merge(@storage[i])
    end
  end

end