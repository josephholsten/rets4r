require 'nokogiri'

module RETS4R
  class Client
    class Metadata < DelegateClass(Hash)
      def initialize
        super(Hash.new {|l, k| l[k] = Hash.new(&l.default_proc)})
      end

      class CompactDocument < Nokogiri::XML::SAX::Document
        DELIMITER = "\t"

        def self.parse_file(filename)
          new.parse_file(filename)
        end

        def initialize
          @parser = Nokogiri::XML::SAX::Parser.new(self)
        end

        def parse_file(filename = 'metadata.xml')
          parse(File.open(filename))
        end

        def parse(content)
          @metadata = Metadata.new
          @stack    = []
          @current_content = ''
          @parser.parse(content)
          @metadata
        end

        def start_element name, raw_attrs = []
          attrs = Hash[*raw_attrs.flatten]

          case name.upcase
          when 'DATA'
            @current_content = ''
          when 'COLUMNS'
            @current_content = ''
            @columns = []
          when 'COMMENTS'
            @current_content = ''
          else
            @stack << [name.upcase, attrs]
          end
        end

        def end_element name
          case name.upcase
          when 'DATA'
            process_content_as_data
          when 'COLUMNS'
            process_content_as_columns
          when 'SYSTEM'
            process_content_as_system
          when 'COMMENTS'
            process_content_as_comments
          else
            @stack.pop
          end
        end

        def characters content
          @current_content << content if receives_content? @stack.last[0]
        end

        private

          def receives_content? tag
            tag =~ /^(X-)?(METADATA|SYSTEM)/i
          end

          def process_content_as_columns
            @columns = @current_content.split(DELIMITER)
          end

          def process_content_as_data
            data = hashify_current_content
            tag, attrs = @stack.last

            resource = data.delete('ResourceID') || attrs['Resource']
            klass    = data.delete('ClassName')  || attrs['Class']

            case tag
            when 'METADATA-RESOURCE'
              @metadata[resource] = data
            when 'METADATA-CLASS'
              @metadata[resource][:classes][klass] = data
            when 'METADATA-TABLE'
              @metadata[resource][:classes][klass][:tables][data.delete('SystemName')] = data
            when 'METADATA-OBJECT'
              @metadata[resource][:objects][data.delete('ObjectType')] = data
            when 'METADATA-LOOKUP'
              @metadata[resource][:lookups][data.delete('LookupName')] = data
            when 'METADATA-LOOKUP_TYPE'
              @metadata[resource][:lookup_types][attrs['Lookup']][data.delete('Value')] = data
            end
          end

          def process_content_as_system
            tag, attrs = @stack.last

            @metadata.merge! attrs
          end

          def process_content_as_comments
            @metadata['Comments'] = @current_content.strip
          end

          def hashify_current_content
            # So that we can do direct assignment easily, we set the default proc to create
            # hashe for non-existant elements.
            @columns.zip(@current_content.split(DELIMITER)).inject(
              Hash.new(&@metadata.default_proc)) do |h, (k,v)|
                h[k] = v unless k.empty?
                next h
            end
          end
      end
    end

    ## Kept for compatibility with previous versions.
    MetadataParser = Metadata::CompactDocument
  end
end
