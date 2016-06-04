# encoding: utf-8

class BackgroundUploader < ImageUploader

  version :base
  version :project_background

  version :base do
    process resize_to_fill: [1200,800]
    process convert: :jpg
  end

  version :project_background do
    process resize_to_fit: [1200,1800]
    process convert: :jpg
  end

end

