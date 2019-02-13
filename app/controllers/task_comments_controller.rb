class TaskCommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @task = Task.find(params[:task_id])

    authorize! :create_task_comment, @task

    @comment = @task.task_comments.build(comment_params)
    @comment.user_id = current_user.id

    respond_to do |format|
      if @comment.save
        set_activity(@task, 'created')
        @task.project.interested_users.each do |user|
          NotificationMailer.comment(task_comment: @comment, receiver: user, board_id: @task.board_id).deliver_later
        end       
        format.html  { redirect_to :back, success: t('.success')}
        format.js
      else
        format.html  { redirect_to :back, success: t('.fail') }
        format.js
      end
    end
  end

  def destroy
    comment = TaskComment.find(params[:id])

    authorize! :destroy_task_comment, comment.task

    @comment_id = comment.id
    if comment.destroy
      @success = true
    else
      @success = false
      flash[:error]= comment.errors.full_messages.to_sentence
    end
  end

  private

  def comment_params
    params.require(:task_comment).permit(:body, :attachment, :task_id)
  end

  def set_activity(task = @comment.task, text)
    current_user.create_activity(@comment, text)
  end
end
