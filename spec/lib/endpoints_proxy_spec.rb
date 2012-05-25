# require "rspec"
require 'spec_helper'
# require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'JSON'


describe "Behaviour of EndpointsProxy" do

	before(:all) do
		@url = "http://staging.conceptwiki.org/web-ws/concept/search/byTag"
		@options ={
			:q => "some",
			:query => "some",
			:limit => 25,
			:offset => 0,
			:uuid => 'eeaec894-d856-4106-9fa1-662b1dc6c6f1'
		}

		@tab_string = 'Entry	Protein names	PubMed ID	Comments	Gene names
		Q86YC2	Partner and localizer of BRCA2	17974005; 15616553; 15489334; 14702039; 15302935; 16793542; 17287723; 17200672; 17525332; 19413330; 19423707; 19369211; 19690332; 19264984; 20332121; 20871615; 20871616; 19609323; 18987736; 21618343	Domain (1); Function (1); Involvement in disease (3); Post-translational modification (1); Sequence similarities (1); Subcellular location (1); Subunit structure (1)	PALB2 FANCN
		Q9H265	BRCA2 protein (Fragment)	12100744		BRCA2
		Q9P287	BRCA2 and CDKN1A-interacting protein (P21- and CDK-associated protein 1) (Protein TOK-1)	10878006; 12527204; 14702039; 17974005; 15164054; 15489334; 11313963; 14726710; 15539944; 15713648; 17081983; 17287340; 17947333; 18440304; 21269460	Alternative products (1); Caution (1); Developmental stage (1); Function (1); Miscellaneous (1); Sequence similarities (1); Subcellular location (1); Subunit structure (1); Tissue specificity (1)	BCCIP TOK1
		Q8N137	Centrobin (Centrosomal BRCA2-interacting protein) (LYST-interacting protein 8)	16275750; 15498874; 17974005; 16625196; 15489334; 14702039; 11984006; 17525332	Alternative products (1); Caution (3); Developmental stage (1); Function (1); Post-translational modification (1); Subcellular location (1); Subunit structure (1); Tissue specificity (1)	CNTROB LIP8 PP1221
		Q8IU64	Breast and ovarian cancer susceptibility protein (Breast cancer susceptibility protein BRCA2) (Fragment)	14722926		BRCA2
		Q9NXR7	BRCA1-A complex subunit BRE (BRCA1/BRCA2-containing complex subunit 45) (Brain and reproductive organ-expressed protein)	7826398; 11676476; 14636569; 14702039; 15815621; 15489334; 15465831; 17525341; 19413330; 19214193; 19261746; 19261749; 19261748; 19608861	Alternative products (1); Domain (1); Function (1); Induction (1); Sequence similarities (1); Subcellular location (1); Subunit structure (1); Tissue specificity (1)	BRE BRCC45
		P46736	Lys-63-specific deubiquitinase BRCC36 (EC 3.4.19.-) (BRCA1-A complex subunit BRCC36) (BRCA1/BRCA2-containing complex subunit 3) (BRCA1/BRCA2-containing complex subunit 36) (BRISC complex subunit BRCC36)	1303175; 8247530; 14636569; 14702039; 15772651; 15489334; 16707425; 18077395; 17525341; 19261749; 19261746; 19261748; 19214193; 19202061; 21269460	Alternative products (1); Caution (2); Function (1); Involvement in disease (1); Sequence similarities (2); Subcellular location (1); Subunit structure (1); Tissue specificity (1)	BRCC3 BRCC36 C6.1A CXorf53
		P51587	Breast cancer type 2 susceptibility protein (Fanconi anemia group D1 protein)	8524414; 8589730; 15057823; 9140390; 15115758; 15199141; 15314155; 15689453; 15671039; 15800615; 15967112; 16793542; 17525332; 18212739; 18317453; 19369211; 20729859; 20729858; 20729832; 21084279; 12442171; 19609323; 8665505; 8673091; 8640235; 8640236; 8640237; 9150152; 9654203; 9609997; 10486320; 10323242; 9971877; 10399947; 11062481; 10978364; 11139248; 11241844; 12145750; 12373604; 12097290; 11948123; 12215251; 12442273; 12442274; 12442275; 11948477; 12065746; 12552570; 12938098; 12624724; 12569143; 14670928; 15026808; 15172753; 14746861; 14722926; 15300854; 15365993; 15635067; 17924331; 16825431; 20513136	Function (1); Involvement in disease (5); Post-translational modification (2); Sequence similarities (1); Subunit structure (1); Tissue specificity (1)	BRCA2 FACD FANCD1
		B2ZAH0	BRCA2 (Fragment)'
	end



	it "should exist the module" do
		EndpointsProxy.autocheck().should == true
		false.should == false
	end


	it "module check conceptWiki should ping back" do
		result = EndpointsProxy.autocheck.should be_true
		result = EndpointsProxy.checkConceptAPI.should be_true

puts "proteinLookup endpoint: #{EndpointsProxy.getEndpoint}"

	end



	it "module check coreApi should ping back" do
		result = EndpointsProxy.autocheck.should be_true
		coreApiAlive = EndpointsProxy.checkCoreAPI

#		EndpointsProxy.myProxy.should be_nil
puts "Endpoints checked: #{EndpointsProxy.getEndpointsChecked}"

		EndpointsProxy.getEndpointsChecked.should be > 0
		coreApiAlive.should be_false

puts "Endpoint used: #{EndpointsProxy.getEndpoint}"
	end


	it "make_request should get a response" do
		EndpointsProxy.autocheck.should be_true
		EndpointsProxy.checkConceptAPI.should be_true
		EndpointsProxy.getEndpoint.should_not eq(@url)

		res = EndpointsProxy.make_request(@url, @options)
		res.should_not be_nil
		res.should be_kind_of Net::HTTPResponse # be_kind_of is true if a superclass is got at actual object

	end


	it "uniprot2json should return a json array from tab rows" do
		EndpointsProxy.autocheck.should be_true
		json_str = EndpointsProxy.uniprot2json(@tab_string, 'brca2')

		json_str.length.should be > 0
		expect { JSON.parse(json_str) }.to_not raise_exception (JSON::ParserError)
puts "json_str: #{json_str}"
	end







=begin
	it "should produce a hash" do
		xml = '<?xml version="1.0" encoding="UTF-8"?>
		<deeply>
			<nested>
				<xml>
					<users>
						<user ref="1">
							<usrid>1</usrid>
							<name>Ed Spencer</name>
							<email>ed@sencha.com</email>
						</user>
						<user ref="2">
							<usrid>2</usrid>
							<name>Abe Elias</name>
							<email>abe@sencha.com</email>
						</user>
					</users>
				</xml>
			</nested>
		</deeply>'

		myHash = Hash.from_xml(xml)
		myJson = myHash.to_json

		puts "#{myHash}"
		puts "#{myJson}"

	end
=end

end