module Keyhole
  class Archive < Zip::ZipFile
    def get(url,&block)
      # create tmpdir > http get > extract > call block
    end
  end
end
