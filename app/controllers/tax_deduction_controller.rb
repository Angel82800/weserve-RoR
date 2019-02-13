class TaxDeductionController < ApplicationController
  before_action :get_tax_deduction, except: [:new, :create, :download_tax_receipt]
  before_action :get_user, except: [:new, :create, :download_tax_receipt]
  before_action :get_variables, only: :download_tax_receipt

  def new
    @transaction_id = params["transaction_id"]
  end

  def create
    @tax = TaxDeduction.new(tax_params.merge(user_id: current_user.id))
    if @tax.save
      redirect_to my_wallet_user_path(current_user.id, transaction_id: params["transaction_id"])
    else
      flash[:alert] = @tax.errors.full_messages
      render :new
    end
  end

  def download_tax_receipt
    if @tax
      authorize! :download_tax_receipt, @tax
      respond_to do |format|
        format.html
        format.pdf { respond_pdf }
      end
    else
      respond_to do |format|
        format.pdf { redirect_to new_tax_deduction_path(transaction_id: params["transaction_id"]) }
      end
    end
  end

  def edit
    authorize! :edit, @tax
  end

  def update
    authorize! :update, @tax
    if @tax.update(tax_params)
      redirect_to my_wallet_user_path(@user.id)
    else
      flash[:alert] = @tax.errors.full_messages
      render :edit
    end
  end

  private
  def get_variables
    @payment_tr = PaymentTransaction.find_by(id: params[:transaction_id])
    @user = @payment_tr&.user
    @tax = @user&.tax_deduction
  end

  def respond_pdf
    @payment_tr.update(serial_number: "#{ENV['prefix-receipt-number']}-#{@payment_tr.created_at.year}-#{@payment_tr.id}") if @payment_tr.serial_number.blank?
    filename = "#{@payment_tr.serial_number&.tr('-','_')}.pdf"
    @pdf = render_to_string :pdf => 'tax_deduction', :template => 'tax_deduction/download_tax_receipt.html.erb',
                            :encoding => 'UTF-8',page_height: 370, page_width: 265
    send_data(@pdf, :filename => filename, :type=>'application/pdf')
  end

  def get_tax_deduction
    @tax = TaxDeduction.find(params[:id])
  end

  def get_user
    @user = @tax.user
  end

  def tax_params
    params.require(:donor).permit(:name, :address, :postal_code, :city, :country)
  end
end