require 'pg'
require 'json'
require 'digest'
require_relative '../controller/exceptions/dbi_exceptions'
require_relative 'operators/logger_operator'

module PgHandler

  RAW_TABLE = 'test_id SERIAL PRIMARY KEY, file_sha1 VARCHAR(40), file JSONB, date_time TIMESTAMP'
  RAW_SCHEMA_NAME = 'raw'


  def self.inject_raw(conn, options)
    files = options[:files]

    files.each do |file|
      raise StandarError, LoggerOperator::fatal("InputFile #{file} doesn't exist or is not readable.") unless File.exist?(file) && File.readable?(file)
      table = self.get_name(file, options[:keys])
      begin
        inject_raw_file(conn, file, table)
      rescue DBIExceptions::SHA1Duplicate => e
        puts e.message
        exit(1)
      end
    end
  end


  # injects the json file into
  def self.inject_raw_file(conn, file, table)
    jsonb = self.readfile(file)
    sha1 = Digest::SHA1.file(file).hexdigest
    timestamp = get_timestamp

    begin
      conn.exec('CREATE SCHEMA IF NOT EXISTS raw')
      conn.exec("CREATE TABLE IF NOT EXISTS #{RAW_SCHEMA_NAME}.#{table} (#{RAW_TABLE})")

      if sha1_exists?(conn, table, sha1)
        raise DBIExceptions::SHA1Duplicate, LoggerOperator::error("Duplicate SHA1 for file #{file}")
      else
        conn.exec("INSERT INTO #{RAW_SCHEMA_NAME}.#{table} (file, file_sha1, date_time) VALUES ('#{jsonb}'::jsonb, '#{sha1}', '#{timestamp}')")
        LoggerOperator::info("Inserted jsonb file into #{RAW_SCHEMA_NAME}.#{table}")
      end

    rescue PG::Error => e
      puts e.message
      exit(1)
    end
  end


  # looks into the table to see if SHA1 key already exists
  def self.sha1_exists?(conn, table, hash)
    result = conn.exec("SELECT file_sha1 from #{RAW_SCHEMA_NAME}.#{table} WHERE file_sha1='#{hash}'")
    result.ntuples == 0 ? false : true
  end


  # get a time stamp in the format of YY-MM-DD HH:mm:SS
  def self.get_timestamp
    Time.now.strftime('%F %T')
  end


  # DEPRECATED: get an id number for the test
  def self.get_test_id(conn, table)
    result = conn.exec("SELECT MAX(test_id) FROM #{RAW_SCHEMA_NAME}.#{table}")
    result.getvalue(0,0).nil? ? 1000 : result.getvalue(0,0).to_i + 1
  end


  # determine the name of the table based on metadata keys from the JSON file, join values with '_'
  # e.g. a file has the following metadata:
  #     test_name => reference_linux
  #     configuration => no_java
  # if we name the table using both keys (test_name and run), the table will be named reference_linux_no_java
  def self.get_name(file, name_keys)
    keys = Array.new
    json = self.get_json(file)

    # TODO: potential problem, assumes that the name keys provides are constant metadata that can be found in the first
    # object in the json file.
    name_keys.each do |name|
      raise DBIExceptions::UnknownFieldName,  LoggerOperator::error("Field #{name} does not exist in this file.") if json[name].nil?
      keys << json[name]
    end

    self.normalize_name(keys)
  end


  # normalize table names based on an array of strings
  def self.normalize_name(keys)
    keys = keys.map { |key| key.strip.gsub(' ', '_')}
               .map { |key| key.gsub(/[^0-9a-z_]/i, '')}
               .join('_')
    keys.downcase
  end


  def self.readfile(file)
    begin
      File.read(file)
    rescue => e
      puts e.message
      exit(1)
    end
  end


  def self.get_json(file)
    begin
      json_file = File.read(file)
      JSON.parse(json_file)
    rescue => e
      puts e.message
      exit(1)
    end
  end

end