class Goal < ActiveRecord::Base
  belongs_to :project
  validates_numericality_of :value, greater_than_or_equal_to: 1.00, message: 'Valor deve ser maior ou igual a R$ 1'

  def progress
    ( project.pledged / self.value ) * 100
  end

  def reached?
    progress >= 100
  end

end
