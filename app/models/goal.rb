class Goal < ActiveRecord::Base
  belongs_to :project

  def progress
    ( project.pledged / self.value ) * 100
  end

end
