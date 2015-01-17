module RBFS

  class File
    attr_accessor :data

    def initialize(data = nil)
      @data = data
    end

    def data_type
      if    data.is_a?(Numeric)  then :number
      elsif data.is_a?(String)   then :string
      elsif data.is_a?(Symbol)   then :symbol
      elsif data.is_a?(NilClass) then :nil
      else                            :boolean
      end
    end

    def serialize
      "#{data_type}:#{data}"
    end

    def self.parse(string_data)
      type_data, data = string_data.split(':')
      if    type_data == 'string' then File.new(data)
      elsif type_data == 'symbol' then File.new(data.to_sym)
      elsif type_data == 'nil'    then File.new
      elsif data.include?('.')    then File.new(data.to_f)
      elsif type_data == 'number' then File.new(data.to_i)
      else                             File.new(data == 'true')
      end
    end

    def self.parse_multiple_files(string_data)
      files = {}
      file_counter = string_data.partition(':').first.to_i
      not_parsed = string_data.partition(':').last
      file_counter.times do
        file_name, file_size, tail = not_parsed.split(':', 3)
        files[file_name] = File.parse tail[0, file_size.to_i]
        not_parsed = tail[file_size.to_i, not_parsed.size]
      end
      [files, not_parsed]
    end
  end


  class Directory
    def initialize(files = {}, directories = {})
      @folder = {files: files, directories: directories}
    end

    def add_file(name, file = File.new)
      @folder[:files][name] = file
    end

    def add_directory(name, directory = Directory.new)
      @folder[:directories][name] = directory
    end

    def files
      @folder[:files]
    end

    def directories
      @folder[:directories]
    end

    def [](name)
      directories.fetch(name, files[name])
    end

    def serialize
      serialized = ''

      serialized.concat(files.size.to_s).concat(':')
      files.each_pair do |key, value|
        serialized.concat "#{key}:#{value.serialize.length}:#{value.serialize}"
      end

      serialized.concat(directories.size.to_s).concat(':')
      directories.each_pair do |key, value|
        serialized.concat "#{key}:#{value.serialize.length}:#{value.serialize}"
      end

      serialized
    end

    def self.parse(string_data)
      folders, (files, not_parsed) ={}, File.parse_multiple_files(string_data)
      folder_counter = not_parsed.partition(':').first.to_i
      not_parsed = not_parsed.partition(':').last
      folder_counter.times do
        folder_name, folder_size, tail = not_parsed.split(':', 3)
        folders[folder_name] = Directory.parse(tail[0, folder_size.to_i])
        not_parsed = tail[folder_size.to_i, not_parsed.size]
      end
      Directory.new(files, folders)
    end
  end
end
