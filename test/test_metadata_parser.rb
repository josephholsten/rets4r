$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "."))
require 'test_helper'
require 'rets4r/client/parsers/metadata'

class RETS4R::Client::TestMetadataParser < Test::Unit::TestCase
  context RETS4R::Client::MetadataParser do
    setup do
      @metadata_path = File.expand_path('data/1.5/metadata.xml', File.dirname(__FILE__))
      @mdp = RETS4R::Client::MetadataParser.new
    end

    context "when compact metadata" do
      setup do
        @results = @mdp.parse_file(@metadata_path)
      end

      should "have clean stack upon completion" do
        assert @mdp.instance_variable_get(:@stack).empty?
      end

      context "when METADATA-SYSTEM" do
        should "add system name" do
          assert_equal 'North Texas Real Estate Information System', @results['SystemDescription']
        end

        should "add system id" do
          assert_equal 'NTREIS', @results['SystemID']
        end

        should "add comments" do
          assert_equal 'This is a comment line', @results['Comments']
        end
      end

      context "when METADATA-RESOURCE" do
        should "create key for each resource" do
          ['Tax', 'Agent', 'Property'].each do |resource|
            assert @results.has_key?(resource)
          end
        end

        should "add resource attributes for Property" do
          property = @results['Property']

          assert_equal '1.00.000', property['ValidationExternalVersion']
          assert_equal '1.00.000', property['ValidationExpressionVersion']
          assert_equal '1.00.000', property['ClassVersion']
          assert_equal '1.00.000', property['LookupVersion']
          assert_equal '1.00.000', property['ObjectVersion']
          assert_equal '5',        property['ClassCount']
          assert_equal '1.00.000', property['EditMaskVersion']
          assert_equal 'LN',       property['KeyField']
          assert_equal '1.00.000', property['UpdateHelpVersion']
          assert_equal '1.00.000', property['SearchHelpVersion']
          assert_equal '1.00.000', property['ValidationLookupVersion']
          assert_equal 'Property', property['VisibleName']
          assert_equal 'Property Tables', property['Description']
          assert_equal 'Sat, 20 Mar 2002 12:03:38 GMT', property['LookupDate']
          assert_equal 'Sat, 20 Mar 2002 12:03:38 GMT', property['ValidationExpressionDate']
          assert_equal 'Sat, 20 Mar 2002 12:03:38 GMT', property['UpdateHelpDate']
          assert_equal 'Sat, 20 Mar 2002 12:03:38 GMT', property['ValidationLookupDate']
          assert_equal 'Sat, 20 Mar 2002 12:03:38 GMT', property['EditMaskDate']
          assert_equal 'Sat, 20 Mar 2002 12:03:38 GMT', property['ObjectDate']
          assert_equal 'Sat, 20 Mar 2002 12:03:38 GMT', property['SearchHelpDate']
          assert_equal 'Sat, 20 Mar 2002 12:03:38 GMT', property['ClassDate']
          assert_equal 'Sat, 20 Mar 2002 12:03:38 GMT', property['ValidationExternalDate']
        end
      end

      context "when METADATA-CLASS" do
        should "add class data to appropriate resource" do
          assert_equal 5, @results['Property'][:classes].keys.size
        end

        should "add class attributes for RES" do
          res_class = @results['Property'][:classes]['RES']

          assert_equal 'Sat, 20 Mar 2002 12:03:38 GMT', res_class['UpdateDate']
          assert_equal '1.00.000',                      res_class['TableVersion']
          assert_equal '1.00.000',                      res_class['UpdateVersion']
          assert_equal 'Sat, 20 Mar 2002 12:03:38 GMT', res_class['TableDate']
          assert_equal 'Single Family Residential',     res_class['Description']
          assert_equal 'Single Family',                 res_class['VisibleName']
          assert_equal 'Residential',                   res_class['StandardName']
        end
      end

      context "when METADATA-TABLE" do
        should "add table data to appropriate class" do
          assert_equal 8, @results['Property'][:classes]['RES'][:tables].keys.size
        end

        should "add VEW table attributes to class" do
          vew_table = @results['Property'][:classes]['RES'][:tables]['VEW']

          assert_equal '',     vew_table['MetadataEntryID']
          assert_equal '',     vew_table['Required']
          assert_equal 'VEW',  vew_table['DBName']
          assert_equal '',     vew_table['Default']
          assert_equal '',     vew_table['Maximum']
          assert_equal 'Left', vew_table['Alignment']
          assert_equal 'View', vew_table['LongName']
          assert_equal '',     vew_table['Units']
          assert_equal '1',    vew_table['Searchable']
          assert_equal 'Long', vew_table['DataType']
          assert_equal '',     vew_table['Minimum']
          assert_equal 'VEW',  vew_table['LookupName']
          assert_equal '',     vew_table['SearchHelpID']
          assert_equal '',     vew_table['EditMaskID']
          assert_equal '10',   vew_table['Maximumlength']
          assert_equal '1',    vew_table['ModTimeStamp']
          assert_equal '',     vew_table['Index']
          assert_equal '1',    vew_table['MaxSelect']
          assert_equal 'View', vew_table['ShortName']
          assert_equal '0',    vew_table['UseSeparator']
          assert_equal '0',    vew_table['Precision']
          assert_equal 'View', vew_table['StandardName']
          assert_equal 'LookupBitmask', vew_table['Interpretation']
          assert_nil vew_table['KeyQuery']
          assert_nil vew_table['ForeignKey']
          assert_nil vew_table['ForeignField']
          assert_nil vew_table['KeySelect']
        end
      end

      context "when METADATA-OBJECT" do
        should "add property obects to Property resource" do
          assert_equal 2, @results['Property'][:objects].keys.size
        end

        should "add thumbnail object to Property resource" do
          thumbnail = @results['Property'][:objects]['Thumbnail']

          assert_equal 'PhotoTimestap', thumbnail['ObjectTimeStamp']
          assert_equal '1',             thumbnail['MetadataEntryID']
          assert_equal 'image/jpeg',    thumbnail['MIMEType']
          assert_equal 'PhotoCount',    thumbnail['ObjectCount']
          assert_equal 'Small Photos',  thumbnail['VisibleName']
          assert_equal 'image',         thumbnail['StandardName']
          assert_equal 'Low Resolution Property Photos', thumbnail['Description']
        end
      end

      context "when METADATA-LOOKUP" do
        should "add lookups to Property resource" do
          assert_equal 2, @results['Property'][:lookups].keys.size
        end

        should "add '1' lookup to Property resource" do
          lookup = @results['Property'][:lookups]['1']

          assert_nil               lookup['MetadataEntryID']
          assert_equal '1.00.000', lookup['Version']
          assert_equal 'Status',   lookup['VisibleName']
          assert_equal 'Sat, 20 Mar 2002 12:03:38 GMT', lookup['Date']
        end
      end

      context "when METADATA-LOOKUP_TYPE" do
        setup do
          @lookup_types = @results['Property'][:lookup_types]
        end

        should "add lookup types to Property resource" do
          assert_equal 1, @lookup_types.keys.size
        end

        should "add AR lookup types to Property resource" do
          assert_equal 4, @lookup_types['AR'].keys.size
        end

        should "add AR lookup value '4' to lookup types" do
          assert_nil @lookup_types['AR']['4']['MetadataEntryID']
          assert_equal 'Downtown Redmond', @lookup_types['AR']['4']['LongValue']
          assert_equal 'Dntn Rdmd',        @lookup_types['AR']['4']['ShortValue']
        end
      end

      context "when METADATA-SEARCH_HELP" do
        context "when Property resource" do
          setup do
            @search_help = @results['Property'][:search_help]
          end

          should "add all search help" do
            assert_equal 2, @search_help.size
          end

          should "add search help 1" do
            assert_equal "Enter the number in the following format dxd", @search_help['1']['Value']
          end
        end
      end

      context "when METADATA-EDITMASK" do
        context "when Property resource" do
          setup do
            @edit_masks = @results['Property'][:edit_masks]
          end

          should "add all edit masks" do
            assert_equal 2, @edit_masks.size
          end

          should "add edit mask 1" do
            assert_equal "[0-9]{1,2}[x][0-9]{1,2}", @edit_masks['1']['Value']
          end
        end
      end

      context "when METADATA-FOREIGNKEYS" do
        should "add all foreign keys" do
          assert_equal 9, @results[:foreign_keys].keys.size
        end

        should "add foreign key 6" do
          fk = @results[:foreign_keys]['6']

          assert_equal 'Agent',          fk['CHILD_RESOURCE_ID']
          assert_equal 'RES',            fk['PARENT_CLASS_ID']
          assert_equal 'Property',       fk['PARENT_RESOURCE_ID']
          assert_equal 'SellingAgentID', fk['PARENT_SYSTEMNAME']
          assert_equal 'AgentID',        fk['CHILD_SYSTEMNAME']
        end
      end
    end
  end
end