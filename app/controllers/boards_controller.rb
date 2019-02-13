class BoardsController < ApplicationController
  authorize_resource

  respond_to :js
  before_action :load_tasks, only: [:show]
  before_action :project
  before_action :set_priority, only: :create

  def index
    respond_to do |format|
      format.html { redirect_to project_path(@project) }
      format.js { redirect_to action: :show, id: @project.boards_sort_by_priority.first.id }
    end
  end

  def show
  end

  def create
    board = Board.new(board_params)
    if board.save
      flash[:notice] = t('.success')
      redirect_to action: :show, id: board.id
    else
      head :unprocessable_entity
    end
  end

  def update
    if board.update_attributes(board_params)
      flash[:notice] = t('.success')
      redirect_to action: :show, id: board.id
    else
      head :unprocessable_entity
    end
  end

  def destroy
    board.tasks.update_all board_id: backup_board_id
    if board.destroy
      flash[:notice] = t('.success')
      redirect_to action: :index, status: :see_other
    else
      head :unprocessable_entity
    end
  end

  private

  def project
    @project ||= Project.not_hidden.find(params[:project_id])
  end

  def set_priority
    params[:board][:priority] = @project.boards_max_priority + 1
  end

  def boards
    @boards ||= project.boards
  end

  def board
    @board ||= boards.find_by(id: params[:id])
  end

  def load_tasks
    # Use unscoped to bypass default_scope order by created_at
    respond_to do |format|
      if board.blank?
        format.js { redirect_to project_path(@project) }
      else
        tasks = board.tasks.unscope(:order)
        @tasks_count = tasks.count
        @sourcing_tasks = tasks.where(state: %w(accepted incompleted)).order(:priority)
        @doing_tasks = tasks.doing
        @suggested_tasks = tasks.suggested_task
        @reviewing_tasks = tasks.reviewing
        @done_tasks = tasks.completed
        format.js {}
      end
      format.html { redirect_to project_path(@project) }
    end
  end

  def board_params
    params.require(:board).permit(:title, :project_id, :priority)
  end

  def backup_board_id
    first_board ||= @project.boards_sort_by_priority.first
    board.eql?(first_board) ? @project.boards_sort_by_priority.second&.id : first_board.id
  end
end
