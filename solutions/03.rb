module RBFS

  class Parser

    def initialize(data)
      @not_parsed = data
    end

    def split_to_sections
      counter, @not_parsed = @not_parsed.split(':', 2)
      counter.to_i.times do
        name, size, tail = @not_parsed.split(':', 3)
        yield name, tail[0, size.to_i]
        @not_parsed = tail[size.to_i.. -1]
      end
    end

    def parse_file
      type_data, data = @not_parsed.split(':', 2)
      if    type_data == 'string' then File.new(data)
      elsif type_data == 'symbol' then File.new(data.to_sym)
      elsif type_data == 'nil'    then File.new
      elsif data.include?('.')    then File.new(data.to_f)
      elsif type_data == 'number' then File.new(data.to_i)
      else                             File.new(data == 'true')
      end
    end

    def parse_directory
      directory = Directory.new
            
      split_to_sections do |name, data| 
        directory.add_file(name, File.parse(data))
      end

      split_to_sections do |name, data|
        directory.add_directory(name, Directory.parse(data))
      end

      directory
    end
  end

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
      Parser.new(string_data).parse_file
    end
  end


  class Directory
    attr_reader :files, :directories
    
    def initialize(files = {}, directories = {})
      @files = files
      @directories = directories
    end

    def add_file(name, file = File.new)
      @files[name] = file
    end

    def add_directory(name, directory = Directory.new)
      @directories[name] = directory
    end

    def [](name)
      @directories.fetch(name, files[name])
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
      Parser.new(string_data).parse_directory
    end
  end
end
