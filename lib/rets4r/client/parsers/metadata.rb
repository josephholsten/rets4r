require 'delegate'
require 'nokogiri'

module RETS4R
  class Client

    # Provides a Hash-like representation of metadata.
    # Currently only compact metadata is supported.
    #
    # String keys represent data that has come from the parsed metadata file.
    #
    # Symbol keys tend to indicate categories such as :lookup_types. Additionally,
    # there are corresponding _date and _version keys for each category.
    # e.g. :lookup_types, :lookup_types_date, and :lookup_types_version
    #
    # The reason these are symbols is to help distinguish them from the parsed data.
    #
    # All categories are pluralized snakecase except for :search_help.
    #
    # The following is the basic structure of a metadata object, which generally follows the
    # RETS specification metadata structure, but with a few notable non-nested exceptions such as
    # lookup_types.
    #
    # {:foreign_keys => {<fkey_id> => {...}},
    #  'Comments'    => ...,
    #  'SystemID'    => ...,
    #  'SystemDescription' => ...
    #  <Resource Name> => {...,
    #                   :lookup_types => {
    #                     <Lookup Name> => {<Lookup Type Value> => {...}}},
    #
    #           :objects         => {<Object Type> => {...}},
    #           :objects_date    => ...,
    #           :objects_version => ...,
    #           :classes => {<Class Name>: => {...,
    #                                          :tables => {<System Name> => {...}}},
    #           :search_help => {<Search Help ID> => {...}},
    #           :lookups     => {<Lookup Name>    => {...}}
    #           :edit_masks: => {<Edit Mask ID>:  => {...}}
    #
    # Update related metadata is currently NOT handled by the parser. The following metadata
    # types ARE handled by the parser: System, Resource, Class, Table, Object, Lookup,
    # LookupType, ForeignKeys, SearchHelp, and EditMask.
    #
    # To generate a metadata object, use one of CompactDocument parse methods.

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

      def search_help(resource)
        resource(resource)[:search_help] ||= {}
      end

      def edit_masks(resource)
        resource(resource)[:edit_masks] ||= {}
      end

      def foreign_keys
        self[:foreign_keys] ||= {}
      end

      # Nokogiri SAX compact metadata parser
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

            apply_tag_attributes
          end
        end

        def end_element name
          case name.upcase
          when 'DATA'
            process_content_as_data
          when 'COLUMNS'
            process_content_as_columns
          when 'SYSTEM'
            # unlike the other tags here, SYSTEM cotains its own content so it
            # needs to be processed as well as removed from the stack.
            process_content_as_system
            @stack.pop
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
            when 'METADATA-FOREIGNKEYS'
              @metadata.foreign_keys[data.delete('ForeignKeyID')] = data
            when 'METADATA-SEARCH_HELP'
              @metadata.search_help(resource)[data.delete('SearchHelpID')] = data
            when 'METADATA-EDITMASK'
              @metadata.edit_masks(resource)[data.delete('EditMaskID')] = data
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

          # Adds the tag attributes date and version to the top level tag
          # if it corresponds to a container.
          def apply_tag_attributes
            tag, attrs = @stack.last

            container = container_for(tag, attrs)
            base      = category_sym_from_tag(tag)

            if container && base
              container["#{base}_date".to_sym]    = attrs['Date']
              container["#{base}_version".to_sym] = attrs['Version']
            end

            container
          end

          def container_for(tag, attrs)
            resource = attrs['Resource']

            case tag
            when 'METADATA-TABLE'
              @metadata.resource_class(resource, attrs['Class'])
            when 'METADATA-FOREIGNKEYS'
              @metadata.foreign_keys
            else
              @metadata.resource(resource)
            end
          end

          def category_sym_from_tag(tag)
            case tag
            when 'METADATA-CLASS'       then :classes
            when 'METADATA-TABLE'       then :tables
            when 'METADATA-OBJECT'      then :objects
            when 'METADATA-LOOKUP'      then :lookups
            when 'METADATA-LOOKUP_TYPE' then :lookup_types
            when 'METADATA-FOREIGNKEYS' then :foreign_keys
            when 'METADATA-SEARCH_HELP' then :search_help
            when 'METADATA-EDITMASK'    then :edit_masks
            else
              nil
            end
          end
      end
    end

    ## Kept for compatibility with previous versions.
    MetadataParser = Metadata::CompactDocument
  end
end
