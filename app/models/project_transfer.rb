class ProjectTransfer < ActiveRecord::Base
  include PgSearch
  belongs_to :project

  validates :amount, presence: true
  validates_numericality_of :amount, greater_than_or_equal_to: 50, allow_blank: true, message: 'Valor deve ser maior que R$50'
  validate :must_have_funds

  scope :with_state, ->(state) { where(state: state) }
  scope :pg_search, ->(name) { joins(:project).where('projects.name = ?', name) }

  def must_have_funds
    errors.add(:base, 'Saldo insuficiente') unless project.available_funds >= (self.amount || 0)
  end
  
  def confirm
    self.update_attribute :state, 'confirmed'
  end

  def unconfirm
    self.update_attribute :state, 'pending'
  end
end
