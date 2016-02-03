class ProjectTransfer < ActiveRecord::Base
  belongs_to :project

  validates :amount, presence: true
  validates_numericality_of :amount, greater_than_or_equal_to: 50, allow_blank: true, message: 'Valor deve ser maior que R$50'
  validate :must_have_funds

  def must_have_funds
    errors.add(:base, 'Saldo insuficiente') unless project.current_funds >= self.amount
  end
end
