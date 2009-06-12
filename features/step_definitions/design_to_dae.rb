Given /^FML document (.*)$/ do |fn|
  @fml = XML::Document.file(fn)
end

Given /^Design ID (.*)$/ do |id|
  @design_id = id
  @design = Floorplanner::Design.new(@fml,id)
  @design.build_geometries
end

When /^I call to_dae method on Floorplanner::Design instance$/ do
  @doc = @design.to_dae
end

Then /^it should return COLLADA document as String$/ do
  @doc.class.should == String
  @dox = XML::Document.string(@doc.gsub(/xmlns=".+"/, ''))
end

Then /^the document should contain Walls$/ do
  @dox.find("//geometry[@id='walls-geom']").length.should > 0
  @dox.find("//node[@id='Walls']").length.should > 0
end

Then /^the document should contain same count of Areas$/ do
  @dox.find("//node[@id='Areas']/node").length.should ==
    @fml.find("//design[id='#{@design_id}']/areas/area").length
end

Then /^the document should contain sun$/ do
  @dox.find("//light[@id='sun']").length.should == 1
end

Then /^the document should be valid$/ do
  xsd = XML::Schema.document(XML::Document.file("xml/collada_schema_1_4.xsd"))
  @dox.validate_schema(xsd).should == true
end
