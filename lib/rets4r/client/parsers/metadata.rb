require 'rexml/document'
require 'yaml'

require 'rets4r/client/parsers/compact'

module RETS4R
  class Client
    class MetadataParser

      TAGS = [ 'METADATA-RESOURCE',
               'METADATA-CLASS',
               'METADATA-TABLE',
               'METADATA-OBJECT',
               'METADATA-LOOKUP',
               'METADATA-LOOKUP_TYPE' ]

      def initialize()
        @parser = RETS4R::Client::CompactDataParser.new
      end

      def parse_file(file = 'metadata.xml')
        xml = File.read(file)
        doc = REXML::Document.new(xml)
        parse(doc)
      end

      def parse(doc)

        rets_resources = {}

        doc.get_elements('/RETS/*').each do |elem|

          next unless TAGS.include?(elem.name)

          columns   = elem.get_elements('COLUMNS')[0]
          rows      = elem.get_elements('DATA')

          data = @parser.parse_data(columns, rows)

          resource_id = elem.attributes['Resource']

          case elem.name
            when 'METADATA-RESOURCE'
              data.each do |resource_info|
                id = resource_info.delete('ResourceID')
                rets_resources[id] = resource_info
              end

            when 'METADATA-CLASS'
              data.each do |class_info|
                class_name = class_info.delete('ClassName')
                rets_resources[resource_id][:classes] ||= {}
                rets_resources[resource_id][:classes][class_name] = class_info
              end

            when 'METADATA-TABLE'
              class_name = elem.attributes['Class']
              data.each do |table_info|
                system_name = table_info.delete('SystemName')
                rets_resources[resource_id][:classes][class_name][:tables] ||= {}
                rets_resources[resource_id][:classes][class_name][:tables][system_name] = table_info
              end

            when 'METADATA-OBJECT'
              data.each do |object_info|
                object_type = object_info.delete('ObjectType')
                rets_resources[resource_id][:objects] ||= {}
                rets_resources[resource_id][:objects][object_type] = object_info
              end

            when 'METADATA-LOOKUP'
              data.each do |lookup_info|
                lookup_name = lookup_info.delete('LookupName')
                rets_resources[resource_id][:lookups] ||= {}
                rets_resources[resource_id][:lookups][lookup_name] = lookup_info
              end

            when 'METADATA-LOOKUP_TYPE'
              lookup = elem.attributes['Lookup']
              rets_resources[resource_id][:lookup_types] ||= {}
              rets_resources[resource_id][:lookup_types][lookup] = {}
              data.each do |lookup_type_info|
                value = lookup_type_info.delete('Value')
                rets_resources[resource_id][:lookup_types][lookup][value] = lookup_type_info
              end
          end
        end

        rets_resources
      end
    end
  end
end
