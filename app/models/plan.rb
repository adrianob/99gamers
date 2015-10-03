# coding: utf-8
class Plan < ActiveRecord::Base
  belongs_to :project
  has_many :subscriptions
end
