module Keyhole
  class Archive < Zip::ZipFile
    DAE_CACHE_PATH = File.join(Floorplanner.config['dae_cache_path'],'dae')
    IMG_CACHE_PATH = File.join(Floorplanner.config['dae_cache_path'],'textures')

    def dae_path(asset_id)
      FileUtils.mkdir_p DAE_CACHE_PATH
      dae = entries.select{|e| e.name.match(/\.dae$/)}.first
      @relative_dae_path = dae.name
      @dae_path = File.join(
        DAE_CACHE_PATH,
        "#{asset_id}_#{File.basename(dae.name)}"
      )
      dae.extract(@dae_path) unless File.exists?(@dae_path)
      @dae_path
    end

    def image_path(asset_id,relative_to_dae,relative_out=false)
      FileUtils.mkdir_p IMG_CACHE_PATH
      img_path = File.join(File.dirname(@relative_dae_path),relative_to_dae)
      target_path = File.join(IMG_CACHE_PATH,asset_id)
      tex_path = File.join(target_path,File.basename(img_path))

      unless File.exists?(tex_path)
        FileUtils.mkdir_p target_path
        zip_image = entries.select{|e| e.name.match(File.basename(img_path)) }.first
        extract( zip_image , tex_path )
      end
      relative_out ? '../textures'+tex_path.gsub(IMG_CACHE_PATH,'') : tex_path
    end

    def destroy
      File.unlink(@dae_path)
    end
  end
end
