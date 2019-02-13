class PayoutDetail < ActiveRecord::Base
  belongs_to :user

  mount_uploader :legal_document, LegalDocumentUploader

  def full_name
    [first_name, last_name].join(" ")
  end
end
