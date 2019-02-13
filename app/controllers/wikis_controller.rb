class WikisController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_wiki, only: [:show, :edit, :update, :destroy]

  # GET /wikis
  # GET /wikis.json
  def index
    @wikis = Wiki.all
  end

  # GET /wikis/1
  # GET /wikis/1.json
  def show
  end

  # GET /wikis/new
  def new
    @project = Project.find(params[:project_id])
     @wiki =   @project.wikis.build
  end

  # GET /wikis/1/edit
  def edit
    @project = Project.find(params[:project_id])
    @wiki.project_id = params[:project_id]
  end

  # POST /wikis
  # POST /wikis.json
  def create
    @wiki = Wiki.new(wiki_params)
    
    @wiki.user_id = current_user.id

    respond_to do |format|
      if @wiki.save
        current_user.create_activity(@wiki, 'created')
        format.html { redirect_to @wiki.project, notice: 'Wiki was successfully created.' }
        format.json { render :show, status: :created, location: @wiki.project }
      else
        format.html { render :new }
        format.json { render json: @wiki.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /wikis/1
  # PATCH/PUT /wikis/1.json
  def update
    respond_to do |format|

      if @wiki.update(wiki_params)
       
        current_user.create_activity(@wiki, 'updated')
        format.html { redirect_to @wiki.project, notice: 'Wiki was successfully updated.' }
        format.json { render :show, status: :ok, location: @wiki.project }
      else
        format.html { render :edit }
        format.json { render json: @wiki.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wikis/1
  # DELETE /wikis/1.json
  def destroy
    @wiki.destroy
    respond_to do |format|
      current_user.create_activities(@wiki, 'destroyed')
      format.html { redirect_to wikis_url, notice: 'Wiki was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wiki
      @wiki = Wiki.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def wiki_params
      params.require(:wiki).permit(:title, :description, :pictureone, :string, :picturetwo, :picturethree, :picturefour, :picturefive, :project_id, :user_id)
    end
end
