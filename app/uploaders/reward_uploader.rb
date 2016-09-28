# encoding: utf-8

class RewardUploader < ImageUploader

  version :thumb

  version :thumb do
    process resize_to_fill: [313,200]
    process convert: :jpg
  end

end
