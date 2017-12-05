class SchedulesController < ApplicationController
  def index
    @schedules = Schedule.all
  end

  def new
    @schedule = Schedule.new
  end

  def create
    @schedule = Schedule.new(params[:schedule])
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
end
