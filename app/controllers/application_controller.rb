class ApplicationController < ActionController::Base
  before_action :authenticate_channel!
  protect_from_forgery with: :exception

  def datetime_from_js_date_picker(object_params, js_date_key, rails_time_key)
    js_date = object_params[js_date_key].to_date
    hours = object_params["#{rails_time_key}(4i)".to_sym]
    minutes = object_params["#{rails_time_key}(5i)".to_sym]
    Time.zone.local(js_date.year, js_date.month, js_date.day, hours, minutes)
  end

  def date_from_js_date_picker(object_params, js_date_key)
    object_params[js_date_key].to_date
  end
end
