# encoding: utf-8

class CoverUploader < ImageUploader

  version :base
  version :project_cover

  version :base do
    process resize_to_fill: [1200,800]
    process convert: :jpg
  end

  version :project_cover do
    process resize_to_fit: [1200,1800]
    process convert: :jpg
  end

end

