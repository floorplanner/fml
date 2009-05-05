module KML
  class Archive < Zip::ZipFile
    def initialize(fn,&block)
      super(fn,Zip::ZipFile::CREATE)
      begin
        mkdir("images")
        mkdir("models")
      rescue Errno::EEXIST
      end
      @documents = []
      if block
        block.call(self)
        close
      end
    end

    def add_image(fn)
      path = File.join("images",File.basename(fn))
      begin
        add(path,fn)
      rescue Zip::ZipEntryExistsError
        puts "File #{path} exists, skipping"
      end
    end

    def add_model(fn)
      path = File.join("models",File.basename(fn))
      begin
        add(path,fn)
      rescue Zip::ZipEntryExistsError
        puts "File #{path} exists, skipping"
      end
    end

    def add_document(doc)
      @documents << doc
    end

    def close
      Dir.mktmpdir do |tmpdir|
        @documents.each_with_index do |doc,i|
          fn = File.join(tmpdir,"doc_#{i}.kml")
          doc.save(fn)
          begin
            add(File.basename(fn),fn)
          rescue Zip::ZipEntryExistsError
            puts "File doc_#{i}.kml exists, skipping"
          end
        end
        super
      end
    end
  end
end
