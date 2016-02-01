require 'csv'
require 'json'
require 'time'
require 'fileutils'
require_relative '../exceptions/parser_exceptions'
require_relative 'logger_operator'

module OutputOperator

  DEFAULT_CONFIG_FILE = File.join(File.dirname(__FILE__), '../../../etc/default_configuration.json')

  # generates a random name for the output file
  def self.get_unique_name
    Time.now.to_i
  end


  def self.output(format, location, file, flavour_name, epoch)
    filename = file.filename
    data = file.data_store[flavour_name]
    metadata = file.metadata_store
    combined = data.add_to_each_line(metadata)
    unless data.empty?
      if format == 'csv'
        self.output_csv(location, filename, flavour_name, combined, epoch)
      elsif format == 'json'
        self.output_json(location, filename, flavour_name, combined, epoch)
      end
    end
  end

  # writes a csv file. sample CSV output:
  # test name,date ran,machines,scope,page size,count,duration
  # Concurrent Commit,2015-06-15 22:34:05,lin5/load5,no filters,100,1,3252
  # Concurrent Commit,2015-06-15 22:34:05,lin5/load5,no filters,100,2,1567
  # Concurrent Commit,2015-06-15 22:34:05,lin5/load5,no filters,100,3,1412
  # Concurrent Commit,2015-06-15 22:34:05,lin5/load5,no filters,100,4,1348
  # ...
  def self.output_csv(location, filename, flavour_name, combined_hash, epoch)
    root = make_results_dir("#{location}/gelato/#{filename}")
    path = "#{root}/#{flavour_name}_#{epoch}.csv"

    keys = combined_hash[0].keys
    CSV.open(path, 'wb') do |csv|
      csv << keys
      combined_hash.each do |row|
        row_data = Array.new
        keys.each do |key|
          row_data << row[key]
        end
        csv << row_data
      end
    end

    LoggerOperator::info("Created: #{path}")
  end


  # writes a json file. sample JSON output:
  #    {
  #     "test name": "Concurrent Commit",
  #     "sut": "lin5",
  #     "load": "load5",
  #     "date ran": "2015-06-16 00:36:47",
  #     "data": [
  #     {
  #         "scope": "no filters ",
  #         "page size": "100",
  #         "count": "1",
  #         "duration": "3329"
  #     },
  #     {
  #         "scope": "no filters ",
  #         "page size": "100",
  #         "count": "2",
  #         "duration": "1899"
  #     },
  #      ...
  #     ]}
  def self.output_json(location, filename, flavour_name, combined, epoch)
    root = make_results_dir("#{location}/gelato/#{filename}")
    path = "#{root}/#{flavour_name}_#{epoch}.json"

    File.open(path,'w') do |file|
      file.write(JSON.pretty_generate(combined))
    end

    LoggerOperator::info("Created: #{path}")
  end


  # creates dir to store output, with a unique names using the timestamp
  def self.make_results_dir(path)
    FileUtils.mkdir_p(path) unless File.directory?(path)
    path
  end


  # generates a default configuration file at the path
  # if path wasn't specified, then default to the user's home directory
  def self.new_default_configuration(name, path = nil)
    raise ParserExceptions::NilParameter, LoggerOperator::fatal('A name must be provided to generate the default configuration file.') if name.nil?

    if path.nil?
      file_path = File.join(Dir.home, "#{name}.json")
    else
      file_path = File.join(path, "#{name}.json")
    end

    File.open(DEFAULT_CONFIG_FILE, 'rb') do |input|
      File.open(file_path, 'wb') do |output|
        while buff = input.read(4096)
          output.write(buff)
        end
      end
    end

    file_path
  end

end
