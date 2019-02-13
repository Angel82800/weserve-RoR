class WorkRecordsController < ApplicationController
  before_action :set_work_record, only: [:show, :edit, :update, :destroy]

  # GET /work_records
  # GET /work_records.json
  def index
    @work_records = WorkRecord.all
  end

  # GET /work_records/1
  # GET /work_records/1.json
  def show
  end

  # GET /work_records/new
  def new
    @work_record = WorkRecord.new
  end

  # GET /work_records/1/edit
  def edit
  end

  # POST /work_records
  # POST /work_records.json
  def create
    @work_record = WorkRecord.new(work_record_params)

    respond_to do |format|
      if @work_record.save
        format.html { redirect_to @work_record, notice: 'Work record was successfully created.' }
        format.json { render :show, status: :created, location: @work_record }
      else
        format.html { render :new }
        format.json { render json: @work_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /work_records/1
  # PATCH/PUT /work_records/1.json
  def update
    respond_to do |format|
      if @work_record.update(work_record_params)
        format.html { redirect_to @work_record, notice: 'Work record was successfully updated.' }
        format.json { render :show, status: :ok, location: @work_record }
      else
        format.html { render :edit }
        format.json { render json: @work_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /work_records/1
  # DELETE /work_records/1.json
  def destroy
    @work_record.destroy
    respond_to do |format|
      format.html { redirect_to work_records_url, notice: 'Work record was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_work_record
      @work_record = WorkRecord.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def work_record_params
      params.fetch(:work_record, {})
    end
end
