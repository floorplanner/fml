module Floorplanner
  class Document
    def initialize(fn)
      @xml = XML::Document.file(fn)
    end
    def to_dae
      # create blank COLLADA document
      # call place() for each <fml:object>
      # create new Background from self
      # call to_dae on it and place()
    end
  end
end
