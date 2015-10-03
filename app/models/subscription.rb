# coding: utf-8
class Subscription < ActiveRecord::Base
  belongs_to :plan
end

