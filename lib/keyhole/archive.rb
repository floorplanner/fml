module Keyhole
  class Archive < Zip::ZipFile
    CACHE_PATH = File.join(Floorplanner.config['asset_cache_path'],'dae')
    FileUtils.mkdir_p(CACHE_PATH)

    def dae_path
      dae = entries.select{|e| e.name.match(/\.dae$/)}.first
      @dae_path = File.join(
        CACHE_PATH,
        "asset_#{dae.hash.abs.to_s}_#{File.basename(dae.name)}"
      )
      dae.extract(@dae_path) unless File.exists?(@dae_path)
      @dae_path
    end

    def image_files
      # return images path array
    end

    def destroy
      File.unlink(@dae_path)
    end
  end
end
