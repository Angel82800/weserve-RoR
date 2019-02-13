require 'rails_helper'

RSpec.describe TaskComment, :type => :model do
  describe "validations" do
    it "is not possible to create a task without both body and attachment" do
      expect {
        create(:task_comment, body: nil, attachment: nil)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "is possible to create a task without a body if attachment is present" do
      task_comment = create(:task_comment, :with_attachment, body: nil)
      expect(task_comment).to be_persisted
    end

    it "is possible to create a task without an attachment if body is present" do
      task_comment = create(:task_comment, body: 'test', attachment: nil)
      expect(task_comment).to be_persisted
    end

    it "is possible to create a task with both body and attachment" do
      task_comment = create(:task_comment, :with_attachment, body: 'test')
      expect(task_comment).to be_persisted
    end
  end
end

