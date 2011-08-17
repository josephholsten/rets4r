#!/usr/bin/env ruby -w
testdir = File.expand_path('..', __FILE__)
$LOAD_PATH.unshift(testdir) unless $LOAD_PATH.include?(testdir)
require 'test_helper'

require 'rets4r/listing_mapper'
require 'rets4r/listing_service'

class TestListingMapper < Test::Unit::TestCase
  context "ListingMapper" do
    setup do
      listing_service_config_file = PROJECT_ROOT.join('test', 'data', 'listing_service.yml')
      RETS4R::ListingService.configurations = YAML.load_file(listing_service_config_file)
      RETS4R::ListingService.env = 'test'
    end
    should "access select" do
      config = RETS4R::ListingService.connection
      mapper = RETS4R::ListingMapper.new(config)
      assert_equal config[:select], mapper.select
    end
    should "map from rets keys to record keys" do
      original = {
        "ListingID"=>"11322886",
        "AgentID"=>"000533246",
        "Status"=>"act",
        "ListPrice"=>"239000",
        "StreetNumber"=>"8317",
        "StreetName"=>"Thompson",
        "StreetDirection"=>"",
        "Unit"=>"",
        "ZipCode"=>"79606-6652",
        "City"=>"Abilene",
        "County"=>"Taylor",
        "State"=>"TX",
        "LotSize"=>"LTS.5-.99A",
        "SqFt"=>"2825",
        "LivingArea"=>"2",
        "Bedrooms"=>"4",
        "Garage"=>"PARATTACHE,PAROPENER,PARREAR,PARSIDE",
        "YearBuilt"=>"2005",
        "AgentName"=>"CD Boyd, II",

        "GARAGECAP"=>"2",
        "BATHSFULLBASEMENT"=>"",
        "BATHSFULLLEVEL1"=>"",
        "BATHSFULLLEVEL2"=>"",
        "BATHSFULLLEVEL3"=>"",
        "STORIES"=>"2",
        "INTERIOR"=>"INFBAY-WIN,INFCABLE-A,INFDECLTNG,INFHIGHSPD,INFLOFT,INFSOUND-W,INFVAUL-CL,INFWIND-CO",
        "ACRESCULTIVATED"=>"",
        "CARPORTCAP"=>"0",
        "TAXUNEXEMPT"=>"5876",
        "STREETDIRSUFFIX"=>"",
        "NUMSTOCKTANKS"=>"",
        "LOTDIM"=>"87X182",
        "ACRESPRICE"=>"662049",
        "FIREPLACES"=>"1",
        "SUBDIVISION"=>"Belle Vista Estates",
        "UTILITIES"=>"STUASPHALT,UTLCITY-SE,UTLCITY-WA,STUCONCRET",
        "LISTSTATUSFLAG"=>"",
        "NUMDININGAREAS"=>"2",
        "SQFTPRICE"=>"84.6",
        "MAPPAGE"=>"9999",
        "NUMBARNS"=>"",
        "UIDPRP"=>"3211078",
        "NUMRESIDENCE"=>"",
        "LISTPRICELOW"=>"0",
        "MAPBOOK"=>"OT",
        "LOTNUM"=>"",
        "OFFICELIST_OFFICENAM1"=>"McClure, REALTORS",
        "ACRES"=>"0.361",
        "AGENTSELL_FULLNAME"=>"",
        "BATHSHALFLEVEL1"=>"",
        "PROPSUBTYPE"=>"S",
        "ROOMBEDBATHDESC"=>"BBFJET-TUB,BBFLIN-CLO,BBFSEP-SHO,BBFW+I-CLO",
        "BATHSHALFLEVEL2"=>"",
        "LISTPRICEORIG"=>"239000",
        "BATHSHALFLEVEL3"=>"",
        "UID"=>"3211078",
        "OFFICELIST"=>"FMAB",
        "BATHSHALFBASEMENT"=>"",
        "STORIESBLDG"=>"",
        "REMARKS"=>"Custom home built in 05'.  Growing neighborhood convienient to Wylie schools. Abundant living areas and and open space floor plan.Could be 5th BDRM, or upstair BDRM & Bath could be another living area.  Perfect office next to Master. Gourmet sized kitchen, granite countertops, barell ceilings, wonderful storage space!!!!",
        "STREETNUMDISPLAY"=>"8317",
        "PROPSUBTYPEDISPLAY"=>"RES-S",
        "BATHSHALF"=>"0",
        "STYLE"=>"STYRANCH",
        "COMMONFEATURES"=>"",
        "OFFICESELL_OFFICENAM2"=>"",
        "BATHSFULL"=>"3",
        "MAPCOORD"=>"none",
        "SQFTSOURCE"=>"TAX",
        "NUMLAKES"=>"",
        "NUMWELLS"=>"",
        "NUMPONDS"=>"",
        "LOTDESC"=>"LTDSUBDIV"}
      mapper = RETS4R::ListingMapper.new
      actual = mapper.map(original)
      expected = {
        :mls => "11322886",
        :agent_id =>"000533246",
        :rets_updated_at => nil,
        :status=>"act",
        :list_price =>"239000",
        :street_number =>"8317",
        :street_direction => "",
        :street_name=>"Thompson",
        :unit_number =>"",
        :zip_code =>"79606-6652",
        :city => "Abilene",
        :county =>"Taylor",
        :square_feet =>"2825",
        :living_area => "2",
        :baths =>nil,
        :beds => "4",
        :garage => "PARATTACHE,PAROPENER,PARREAR,PARSIDE",
        :year_built => "2005",
      }
      expected.merge(actual).keys.each{|k| assert_equal expected[k], actual[k], "mismatched on key #{k}"}
    end
    context :to_dmql do
      subject { RETS4R::ListingMapper.new.to_dmql( :mls => 5 ) }
      should "be a dmql clause" do
        assert_equal "(ListingID=5)", subject
      end
    end
    context :reverse_map do
      subject { RETS4R::ListingMapper.new.reverse_map( :mls => 5 ) }
      should "be the hash, backards" do
        assert_equal( {'ListingID' => 5 }, subject )
      end
    end
  end
end
