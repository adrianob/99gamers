class ContributedProject < ActiveRecord::Base
  belongs_to :user
  belongs_to :contribution
  belongs_to :subscription

  scope :most_recent_first, ->{ order("online_date DESC, created_at DESC") }
  delegate :recurrent?, :flexible?, :most_recent_first, :decorate, :progress_bar, :progress, :display_pledged, :display_image, :funding_type, :expired?, :time_to_go, :display_expires_at, :state, :permalink, :name, :user, :headline, to: :project

  def project
    Project.find self.id
  end

end
