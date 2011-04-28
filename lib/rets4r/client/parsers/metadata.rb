require 'nokogiri'

module RETS4R
  class Client
    class Metadata < DelegateClass(Hash)

      # The initial version of this would set the hash default_proc to create new
      # hashes that would in turn create new hashes, which is quite clean, but also
      # meant that you couldn't simply check to see if a given key was nil. Because this is
      # meant to be a mostly transparent replacement of the REXML-based parser, I decided to
      # manually create nested hashes as needed in case existing code relied on the
      # existence of nils.

      def initialize
        super(Hash.new)
      end

      ## Helper access methods to ensure that nested hashes are created as needed.

      def resource(name)
        self[name] ||= {}
      end

      def resource_classes(resource)
        resource(resource)[:classes] ||= {}
      end

      def resource_class(resource, klass)
        resource_classes(resource)[klass] ||= {}
      end

      def class_tables(resource, klass)
        resource_class(resource, klass)[:tables] ||= {}
      end

      def resource_objects(resource)
        resource(resource)[:objects] ||= {}
      end

      def resource_lookups(resource)
        resource(resource)[:lookups] ||= {}
      end

      def resource_lookup_types(resource, lookup)
        lookups = resource(resource)[:lookup_types] ||= {}
        lookups[lookup] ||= {}
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

          # TODO add support for additional metadata content
          def process_content_as_data
            data = hashify_current_content
            tag, attrs = @stack.last

            resource = data.delete('ResourceID') || attrs['Resource']
            klass    = data.delete('ClassName')  || attrs['Class']

            case tag
            when 'METADATA-RESOURCE'
              @metadata.resource(resource).merge!(data)
            when 'METADATA-CLASS'
              @metadata.resource_class(resource, klass).merge!(data)
            when 'METADATA-TABLE'
              @metadata.class_tables(resource, klass)[data.delete('SystemName')] = data
            when 'METADATA-OBJECT'
              @metadata.resource_objects(resource)[data.delete('ObjectType')] = data
            when 'METADATA-LOOKUP'
              @metadata.resource_lookups(resource)[data.delete('LookupName')] = data
            when 'METADATA-LOOKUP_TYPE'
              @metadata.resource_lookup_types(resource, attrs['Lookup'])[data.delete('Value')] = data
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
            # While not necessary anymore, I've left the setting of the default_proc to that
            # of the metadata object so that the default value will be consistent throughout
            # all the metadata.
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
