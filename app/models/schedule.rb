class Schedule < ActiveRecord::Base
  validate :times_exist
  validate :event_date_range
  validate :start_before_end
  #  validate :event_time_order_check
  #validates_datetime :end, after: :start, after_message: 'time must be after start time.'
  belongs_to :event

  def times_exist
    false if self.start.blank? || self.end.blank?
  end

  def start_before_end
    raise ActiveRecord::RecordInvalid.new(self) if self.end < self.start
  end

  def event_date_range
    minimum_date = Date.new(2000)
    maximum_date = Date.new(2050)

    if minimum_date > start.to_date
      errors.add(:start, "#{start} is before the minimum date of #{minimum_date}.")
      return false
    end
    if maximum_date < self.start.to_date
      errors.add(:end, "#{self.end} is after the maximum date of #{maximum_date}.")
      return false
    end

  end
end
