require 'open-uri'
require 'find'

module Keyhole
  class Archive < Zip::ZipFile
    
    def initialize(url)
      @url = url
      super(Kernel.open(download_link).path)
    end

    def dae_file
      extract_entries
      Find.find(to_dir) do |path|
        if path =~ /\.dae/
          return File.new(path)
        end
      end
    end

    def destroy
      Dir.rmdir(to_dir)
    end

    private
    def download_link
      "http://#{CONFIG['content_server']}/assets/#{@url}"
    end

    def to_dir
      "assets/#{File.basename(@url).gsub('.','_')}"
    end

    def extracted?
      File.exists?(to_dir)
    end

    def extract_entries
      return if extracted?
      self.each do |entry|
        f_path = File.join(to_dir, entry.name)
        FileUtils.mkdir_p(File.dirname(f_path))
        self.extract(entry, f_path) unless File.exist?(f_path)
      end
    end
  end
end
