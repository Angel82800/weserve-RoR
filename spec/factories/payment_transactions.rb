FactoryGirl.define do
  factory :payment_transaction do
    task nil
    user nil
    amount "999"
    status "MyString"
    payment_date "2017-09-11 23:15:05"
    payment_type "MyString"
    processing_fee "999"
  end
end
