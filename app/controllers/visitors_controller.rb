class VisitorsController < ApplicationController
  before_action :first_project
  before_action :set_gon

  def index
  end

  def landing
    # Comment this codes for now as we don't have active project and all projects are dummys
    # if (session[:counter].nil?)
    #   session[:counter] = 1
    #   session[:counter] = session[:counter] + 0
    # end
    # session[:counter] = session[:counter] + 1
    # if(session[:counter] > 3 || user_signed_in?)
    #   redirect_to home_index_path
    # else
    #   @featured_projects = Project.last(3)
    # end
  end



  private

  def first_project
    @project = Project.first
  end

  def set_gon
    @short_descr_limit = gon.short_descr_limit = Project::SHORT_DESCRIPTION_LIMIT
  end
end
