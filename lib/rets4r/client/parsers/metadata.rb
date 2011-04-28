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
          when 'SYSTEM'
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
            tag =~ /^(X-)?METADATA/i
          end

          def process_content_as_columns
            @columns = @current_content.split(DELIMITER)
          end

          def process_content_as_data
            data = hashify_current_content
            resource_tag, attrs = @stack.last

            case resource_tag
            when 'METADATA-RESOURCE'
              @metadata[data.delete('ResourceID')].merge!(data)
            when 'METADATA-CLASS'
              @metadata[attrs['Resource']][:classes][data.delete('ClassName')].merge!(data)
            when 'METADATA-TABLE'
              @metadata[attrs['Resource']][:classes][attrs['Class']][:tables][data.delete('SystemName')].merge!(data)
            when 'METADATA-OBJECT'
              @metadata[attrs['Resource']][:objects][data.delete('ObjectType')].merge!(data)
            when 'METADATA-LOOKUP'
              @metadata[attrs['Resource']][:lookups][data.delete('LookupName')].merge!(data)
            when 'METADATA-LOOKUP_TYPE'
              @metadata[attrs['Resource']][:lookup_types][attrs['Lookup']][data.delete('Value')].merge!(data)
            end
          end

          def process_content_as_system
            resource_tag, attrs = @stack.last
            @metadata.merge! attrs
          end

          def process_content_as_comments
            @metadata['Comments'] = @current_content
          end

          def hashify_current_content
            @columns.zip(@current_content.split(DELIMITER)).inject({}) do |h, (k,v)|
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
