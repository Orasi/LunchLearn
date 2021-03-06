class WeeklyMailer < ActionMailer::Base
  default from: 'onTapEvents@orasi.com'
  default_url_options[:host] = 'ontap.orasi.com'

  def weekly_mailer(users)
    @weeks_events = Event.joins(:schedules).merge(Schedule.where('start >= ? AND start < ?', DateTime.now.to_date,  DateTime.now.to_date + 7.days))

    @new_events = Event.where('created_at > ?',  DateTime.now.to_date - 7.days)
    @new_events -= @week_events

    @days = {}
    @days[:monday] = []
    @days[:tuesday] = []
    @days[:wednesday] = []
    @days[:thursday] = []
    @days[:friday] = []
    @weeks_events.each do |event|
      day_of_week = Date::DAYNAMES[event.schedules.first.start.wday].downcase.to_sym
      @days[day_of_week].append event
    end

    if @week_events.count > 0 or @new_events.count > 0
      mail(to: users.map{|user| user.email}, subject: 'Events onTap This Week')
    end
  end
end
