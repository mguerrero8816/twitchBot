class SchedulesController < ApplicationController
  def index
    @schedules = Schedule.all
  end

  def new
    @schedule = Schedule.new
  end

  def create
    @schedule = Schedule.new(schedule_params)
    if @schedule.save
      redirect_to(schedules_path)
    else
      render :new
    end
  end

  def edit
    @schedule = Schedule.find(params[:id])
  end

  def update
  end

  private

  def schedule_params
    params[:schedule][:start_at] = datetime_from_js_date_picker(params[:schedule], :start_at_date, :start_at_time)
    params.require(:schedule).permit(:title, :description, :game_id, :start_at)
  end
end
