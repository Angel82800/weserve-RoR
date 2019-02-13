shared_examples "mailjet api email" do
  it 'has the subject as nil' do
    expect(email.subject).to be_nil
  end

  it 'has the empty body' do
    expect(email.body).to eq("")
  end

  it 'has value for every variables' do
    expect(email.delivery_method.settings["Variables"].values).not_to include(nil)
  end

  it 'sends an email' do
    expect { email }.to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  it 'has correct value for  variables' do
    if defined?(mailjet_variables)
      # App prefix remains same and is taken from environment
      mailjet_variables.merge!({ "AppPrefix" => ENV['mailjet_subject_prefix']})
      expect(email.delivery_method.settings["Variables"]).to eq(mailjet_variables)
    end
  end
end
