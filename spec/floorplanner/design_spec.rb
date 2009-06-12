require File.join(File.dirname(__FILE__), "/../spec_helper" )

module Floorplanner
  describe Design do
    context "initializing" do
      before(:each) do
        @fml = mock(XML::Document)
        @did = rand.to_s
      end

      after(:each) do
        design = Design.new(@fml,@did)
      end

      it "should set name" do
        Design::NAME_QUERY.should_receive(:call).with(@did)
        @fml.should_receive("find").and_return([XML::Node.new("name","Some design")])
      end

      it "should set author name" do
        @fml.should_receive("find").with(Design::AUTHOR_QUERY)
      end
    end

    context "buidling geometries" do
      before(:each) do
        @fml = mock(XML::Document)
        node = mock(XML::Node)
        node.stub!(:content)
        @fml.stub!(:find).and_return([node])

        @did = rand.to_s
        @doc = Design.new(@fml,@did)
      end

      it "should create mesh for each area" do
        areas = [mock(XML::Node)]
        color = mock(XML::Node)
        color.should_receive(:content)
        areas[0].should_receive(:find).with('color').and_return([color])
        @fml.should_receive(:find).with(Design::AREAS_QUERY.call(@did)).and_return(areas)
      end

      after(:each) do
        @doc.build_geometries
      end
    end
  end
end
