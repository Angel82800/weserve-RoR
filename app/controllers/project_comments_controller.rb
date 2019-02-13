class ProjectCommentsController < ApplicationController
  before_action :current_project_comment, only: [:show, :edit, :destroy, :update]

  def index
    @comments = ProjectComment.all.paginate(page: params[:page])
  end

  def show
    @project = @comment.project
  end

  def new
  end

  def create
    project = Project.find(params[:project_id])
    @comment = project.project_comments.build(comment_params)
    @comment.user_id = current_user.id

    if @comment.save
      set_activity(project, 'created')
      flash[:success] = t('.success')
      redirect_to :back
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @comment.update_attributes(comment_params)
      set_activity('updated')
      flash[:success] = t('.success')
      redirect_to @comment.project
    else
      render :edit
    end
  end

  def destroy
    @comment.destroy
    set_activity('deleted')
    flash[:success] = t('.success')
    redirect_to users_path
  end

  private

  def comment_params
    params.require(:project_comment).permit(:user_id, :body, :project_id)
  end

  def current_project_comment
    @comment = ProjectComment.find(params[:id])
  end

  def set_activity(project = @comment.project, text)
    current_user.create_activity(@comment, text)
    project.user.create_activity(@comment, text)
  end
end
