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
  @dox = XML::Document.string(@doc)

  # for XPath to work
  @dox.root.namespaces.default_prefix = "dae"
end

Then /^the document should contain Walls$/ do
  @dox.find("//dae:geometry[@id='walls-geom']").length.should > 0
  @dox.find("//dae:node[@id='Walls']").length.should > 0
end

Then /^the document should contain same count of Areas$/ do
  @dox.find("//dae:node[@id='Areas']/dae:node").length.should ==
    @fml.find("//design[id='#{@design_id}']/areas/area").length
end

Then /^the document should contain sun$/ do
  @dox.find("//dae:light[@id='sun']").length.should == 1
end

Then /^the document should be valid$/ do
  xsd = XML::Schema.document(XML::Document.file("xml/collada_schema_1_4.xsd"))
  @dox.validate_schema(xsd).should == true
end
