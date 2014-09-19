class Notification < ActiveRecord::Base
  belongs_to :event
  validates_inclusion_of :status, in: ["new", "rejected", "approved"]
  validates_inclusion_of :notification_type, in: ["attendance", "survey"]
end