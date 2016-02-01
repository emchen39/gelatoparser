
#each file class contains the lines in the file and data storage
require_relative 'data_storage'

class InputFile

  attr_accessor :file_lines, :data_store, :metadata_store, :filename

  def initialize(file_path, flavours)

    @file_lines = FileOperator.readlines(file_path)
    @filename = File.basename(file_path, File.extname(file_path))

    @data_store = Hash.new
    @metadata_store = Hash.new

    flavours.each do |name, flavour|
      @data_store[name] = DataStorage.new(flavour)
    end
  end


  def is_flavour_empty?(flavour)
    @data_store[flavour].empty?
  end


  def get_flavour_list
    @data_store.keys
  end

end