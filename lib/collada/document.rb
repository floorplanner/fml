module Collada
  class Document < XML::Document
    XMLNS = "http://www.collada.org/2005/11/COLLADASchema"
    VISUAL_SCENE_XPATH = '/dae:COLLADA/dae:library_visual_scenes/dae:visual_scene'
    VERSION = "1.4.1"
    def initialize
      super
      self.root = XML::Node.new('COLLADA')
      self.root.namespaces.namespace = XML::Namespace.new(self.root,nil,XMLNS)
      self.root.namespaces.default_prefix = 'dae'
      self.root.attributes['version'] = VERSION
    end

    def << (node)
      root << node
    end

    def self.from_fml(fn)
      docs = Hash.new
      
      stylesheet_doc = XML::Document.file('fml2dae.xsl')
      stylesheet = XSLT::Stylesheet.new(stylesheet_doc)
      fml_doc = XML::Document.file(fn)
      dae_doc = stylesheet.apply(XML::Document.file(fn))
      dae_doc.root.namespaces.default_prefix = 'dae'
      
      # make copies of resulting collada (one for each design)
      dae_doc.find(VISUAL_SCENE_XPATH).each do |design|
        design_id = design.attributes['id']
        design_doc = Collada::Document.new
        dae_doc.root.children.each do |node|
          design_doc << node.copy(true)
        end

        # strip down unnecessary geometries and scenes
        design_doc.find(VISUAL_SCENE_XPATH+"[@id!='#{design_id}']").each {|n| n.remove!}
        design_doc.find("/dae:COLLADA/dae:library_geometries[@id!='#{design_id.gsub(/_scene$/,'')}']").each {|n| n.remove!}

        # calculate vertices positions
        transform_with('Collada::Element::') do |t|
          design_doc.find(t::QUERY).each do |e|
            begin
              t.from_fml(e)
            rescue NoMethodError
            end
          end
        end

        design_doc.find('//dae:height|//dae:thickness').each {|n| n.remove!}
        docs[design_id.gsub(/^design_|_scene$/,'')] = design_doc
      end
      docs
    end
  end
end
