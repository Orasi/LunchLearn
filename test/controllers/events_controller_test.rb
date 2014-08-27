require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  def setup
    @lunchlearn = FactoryGirl.create(:lunchlearnstyle)
    assert @lunchlearn
    @webinar = FactoryGirl.create(:webinarstyle)
    assert @webinar
    @user = FactoryGirl.create(:normal_user)
    assert @user
    @admin = FactoryGirl.create(:admin_user)
    assert @admin
  end

  test 'should not get calendar if user not logged in' do
    get :calendar
    assert_redirected_to :login
  end

  test 'should get calendar if user logged on' do
    get :calendar, {}, current_user_id: @user.id
    assert_response :success
  end

  test 'should be able to get new event page if admin' do
    get :new, { id: @lunchlearn.id }, current_user_id: @admin.id
    assert_response :success
  end

  test 'should not be able to get edit page if not logged in' do
    get :new, id: @lunchlearn.id
    assert_redirected_to :login
  end

  test 'should not be able to get edit page if not admin' do
    get :new, { id: @lunchlearn.id }, current_user_id: @user.id
    assert_redirected_to :calendar
  end

  test 'should not be able to get to new page if not admin' do
    get :new, {}, current_user_id: @user.id
    assert_redirected_to :calendar
  end

  test 'should be able to get to new page if admin' do
    get :new, {}, current_user_id: @admin.id
    assert_response :success
  end

  test 'should be able to get show view if admin' do
    get :show, { id: @lunchlearn.id }, current_user_id: @admin.id
    assert_response :success
  end

  test 'should be able to get show view if not admin' do
    get :show, { id: @lunchlearn.id }, current_user_id: @user.id
    assert_response :success
  end

  test 'should not be able to edit if user not logged in' do
    get :edit, id: @lunchlearn.id
    assert_redirected_to :login
  end

  test 'should be able to edit if admin' do
    get :edit, { id: @lunchlearn.id }, current_user_id: @admin.id
    assert_response :success
  end

  test 'should be able to edit if host' do
    get :edit, { id: @lunchlearn.id }, current_user_id: @lunchlearn.hosts.first.user_id
    assert_response :success
  end

  test 'should not be able to edit if not host or admin' do
    get :edit, { id: @lunchlearn.id }, current_user_id: @user.id
    assert_redirected_to :calendar
  end

  test 'should be able to commit edits if admin' do
    post :edit, { id: @lunchlearn.id }, current_user_id: @admin.id
    assert_response :success
  end

  test 'should be able to commit edits if host' do
    post :edit, { id: @lunchlearn.id }, current_user_id: @lunchlearn.hosts.first.user_id
    assert_response :success
  end

  test 'should not be able to commit post if not admin or event host' do
    post :edit, { id: @lunchlearn.id }, current_user_id: @user.id
    assert_redirected_to :calendar
  end

  test 'should not be able to commit post if not logged in' do
    post :edit, id: @lunchlearn.id
    assert_redirected_to :login
  end

  # views
  test 'should see lunchlearn info if attendee' do
    get :show, { id: @lunchlearn.id }, current_user_id: @lunchlearn.attendees.sample.user_id
   	assert_select 'h4', 'The following users have registered to attend'
  end

  test 'should not see lunchlearn info if not attendee' do
    get :show, { id: @lunchlearn.id }, current_user_id: @user.id
    assert_response :success
    assert_select 'h4', false, 'Information is hidden from the user'
  end

  test 'should see lunchlearn info if host' do
    get :show, { id: @lunchlearn.id }, current_user_id: @lunchlearn.hosts.sample.user_id
    assert_select 'h4', 'The following users have registered to attend'
  end

  test 'should see lunchlearn info if admin' do
    get :show, { id: @lunchlearn.id }, current_user_id: @admin.id
    assert_select 'h4', 'The following users have registered to attend'
  end

  test 'host should be listed on show page' do
    get :show, { id: @lunchlearn.id }, current_user_id: @user.id
    assert_response :success
    assert_select '.h1', /#{@lunchlearn.title}/
  end

  test 'admin should be able to create an event' do
    event = @lunchlearn
    params = {event: {
        title: event.title,
        description: event.description,
        event_date: event.schedules.first.event_date.strftime("%m/%d/%Y"),
        event_time: (event.schedules.first.event_time).to_time,
        end_time: (event.schedules.first.end_time + 1.hour).to_time,
        event_style: 'lunch_and_learn',
        hosts: [1,2,3],
    }}
    post :create, params, {current_user_id: @admin.id}
    assert_nil flash[:error]
  end

  test 'admin should be able to create a webinar' do
    event = @webinar
    params = {event: {
        title: event.title,
        description: event.description,
        event_date: event.schedules.first.event_date.strftime("%m/%d/%Y"),
        event_time: (event.schedules.first.event_time).to_time,
        end_time: (event.schedules.first.end_time + 1.hour).to_time,
        url: "https://www.someurl.com",
        host: "Some Guy Off The Street",
        event_style: 'webinar'
    }}
    post :create, params, {current_user_id: @admin.id}
    assert_nil flash[:error]
  end

  test 'admin should not be able to create a webinar with out url' do
    event = @webinar
    params = {event: {
        title: event.title,
        description: event.description,
        event_date: event.schedules.first.event_date.strftime("%m/%d/%Y"),
        event_time: (event.schedules.first.event_time).to_time,
        end_time: (event.schedules.first.end_time + 1.hour).to_time,
        host: "Some Guy Off The Street",
        event_style: 'webinar'
    }}
    post :create, params, {current_user_id: @admin.id}
    assert_not_nil flash[:error]
    assert_nil flash[:success]
  end


  test 'admin should be not able to create an event without description' do
    event = @lunchlearn
    params = {event: {
        title: event.title,
        event_date: event.schedules.first.event_date.strftime("%m/%d/%Y"),
        event_time: (event.schedules.first.event_time).to_time,
        end_time: (event.schedules.first.end_time + 1.hour).to_time,
        event_style: 'lunch_and_learn'
    }}
    post :create, params, {current_user_id: @admin.id}
    assert_not_nil flash[:error]
    assert_nil flash[:success]
  end

  test 'admin should be not able to create an event without end time ' do
    event = @lunchlearn
    params = {event: {
        title: event.title,
        description: event.description,
        event_date: event.schedules.first.event_date.strftime("%m/%d/%Y"),
        event_time: (event.schedules.first.event_time).to_time,
        event_style: 'lunch_and_learn'
    }}
    post :create, params, {current_user_id: @admin.id}
    assert_not_nil flash[:error]
    assert_nil flash[:success]
  end

  test 'user should not be able to create an event' do
    event = @lunchlearn
    params = {event: {
        title: event.title,
        description: event.description,
        event_date: event.schedules.first.event_date.strftime("%m/%d/%Y"),
        event_time: (event.schedules.first.event_time).to_time,
        end_time: (event.schedules.first.end_time + 1.hour).to_time,
        event_style: 'lunch_and_learn'
    }}
    post :create, params, {current_user_id: @user.id}
    assert_not_nil flash[:error]
    assert_nil flash[:success]
  end

  test 'admin should be able to update an event' do
    event = @webinar
    params = {event: {
        title: event.title + "abc",
        description: event.description + "abc",
        event_date: (event.schedules.first.event_date + 1.day).strftime("%m/%d/%Y"),
        event_time: (event.schedules.first.event_time - 1.hour).to_time,
        end_time: (event.schedules.first.end_time + 1.hour).to_time,
        url: "https://yourmomrocks.com",
        host: "some other host",
        event_style: 'webinar'
    }, id: @webinar.id
    }
    patch :update, params, {current_user_id: @admin.id}
    assert_nil flash[:error], flash[:success]
  end

  test 'admin should not be able to update an event without event time' do
    event = @lunchlearn
    params = {event: {
        title: event.title + "abc",
        description: event.description + "abc",
        event_date: (event.schedules.first.event_date + 1.day).strftime("%m/%d/%Y"),
        end_time: (event.schedules.first.end_time + 1.hour).to_time,
        event_style: 'lunch_and_learn'
    }, id: @lunchlearn.id
    }
    patch :update, params, {current_user_id: @admin.id}
    assert_not_nil flash[:error]
    assert_nil flash[:success]
  end

  test 'admin should not be able to update an event without description' do
    event = @lunchlearn
    params = {event: {
        title: event.title + "abc",
        description: "",
        event_date: (event.schedules.first.event_date + 1.day).strftime("%m/%d/%Y"),
        event_time: (event.schedules.first.event_time - 1.hour).to_time,
        end_time: (event.schedules.first.end_time + 1.hour).to_time,
        event_style: 'lunch_and_learn'
    }, id: @lunchlearn.id
    }
    patch :update, params, {current_user_id: @admin.id}
    assert_not_nil flash[:error]
    assert_nil flash[:success]
  end

  test 'host should be able to update an event' do
    event = @lunchlearn
    params = {event: {
        title: event.title + "abc",
        description: event.description + "abc",
        event_date: (event.schedules.first.event_date + 1.day).strftime("%m/%d/%Y"),
        event_time: (event.schedules.first.event_time - 1.hour).to_time,
        end_time: (event.schedules.first.end_time + 1.hour).to_time,
        url: "https://www.google.com",
        hosts: [2,3,4],
        event_style: 'lunch_and_learn'
    }, id: @lunchlearn.id}
    patch :update, params, {current_user_id: @lunchlearn.hosts.first.user.id}
    assert_nil flash[:error]
  end

  test 'user should not be able to update an event' do
    event = @lunchlearn
    params = {event: {
        title: event.title + "abc",
        description: event.description + "abc",
        event_date: "08/30/2014",
        event_time: (event.schedules.first.event_time - 1.hour).to_time,
        end_time: (event.schedules.first.end_time + 1.hour).to_time
    }, id: @lunchlearn.id
    }
    patch :update,  params, {current_user_id: @user.id}
    assert_not_nil flash[:error], "expected error creating event"
  end

  test 'user should not be able to delete event' do 
    delete :destroy, {id: @webinar.id}, {current_user_id: @user.id}
    assert_not_nil flash[:error]
    assert_equal flash[:error], "You do not have the required permission to edit this content"

  end

  test 'admin should be able to delete event' do
    delete :destroy, {id: @lunchlearn.id}, {current_user_id: @admin.id}
    assert_not_nil flash[:error]
    assert_equal flash[:error], "Event \"some title\" was deleted"

  end


  # Need to create factory trait for event with no attendees
  # test "if no attendees, no users registered should display" do
  #   get :show, {id: @lunchlearn.id}, {current_user_id: @admin.id}
  #   assert_select 'h5', 'No users registered'
  # end

  #  test "next LunchLearn should be displayed in the jumbotron" do
  #    get :calendar,{id: @lunchtwo.id}, {current_user_id: @admin.id}
  #    assert_select 'h5', /Java.*/
  #  end

  #  test "host information should be in the jumbotron" do
  # get :calendar,{id: @lunchone.id}, {current_user_id: @admin.id}
  # assert_select 'h5' do
  #  assert_select 'small',  /.*Hosted by  + @lunchone.lunch_hosts.collect { |w| w.display_name }.join(",")/
  #  end
  #  end

  #  test "lunclearn time and date should be in the jumbotron" do
  # get :calendar,{id: @lunchtwo.id}, {current_user_id: @admin.id}
  # assert_select 'strong', @lunchtwo.lunch_date.to_date.strftime("%B %d, %Y") + " at " + @lunchtwo.lunch_time.strftime("%I:%M %p")+ " to " + @lunchtwo.end_time.strftime("%I:%M %p")
  #  end
end
