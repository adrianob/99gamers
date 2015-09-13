class FundingType < ActiveRecord::Base
  has_many :projects

  def all_or_nothing?
    self.name == 'all_or_nothing'
  end

  def flexible?
    self.name == 'flexible'
  end

  def recurrent?
    self.name == 'recurrent'
  end

end

