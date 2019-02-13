class DiscussionsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_discussion

  # GET /discussions/1/accept
  # GET /discussions/1/accept.json

  def accept
    @discussion.accept_context
    respond_to do |format|
      format.html { redirect_to @discussion.discussable, notice: 'Discussion was successfully accepted.' }
      format.json { render json: {field_name: @discussion.field_name, content: @discussion.context } }
    end
  end

  # DELETE /discussions/1
  # DELETE /discussions/1.json

  def destroy
    @discussion.destroy
    respond_to do |format|
      format.html { redirect_to @discussion.discussable, notice: 'Discussion was successfully destroyed.' }
      format.js   { head :no_content }
    end
  end

  private

  def set_discussion
    @discussion = current_user.admin? ? Discussion.find(params[:id]) : Discussion.of_user(current_user).find(params[:id])
  end
end