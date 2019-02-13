require 'rails_helper'

RSpec.describe TaskCompleteService, vcr: { cassette_name: 'coinbase' } do
  describe "#initialize" do
    let(:task_attributes) do
      { budget: 2_000_000, current_fund: 2_000_000, state: :reviewing }
    end

    let(:task) do
      FactoryGirl.create(:task, :with_associations, :with_balance, task_attributes)
    end

    context "with current_fund is not changed" do

      it "can be initialized with a valid instance of Task class" do
        service_object = described_class.new(task)
        expect(service_object).to be_kind_of(TaskCompleteService)
        expect(service_object.task).to eq(task)
      end

      it "prevents service initialization if wrong argument type is passed" do
        expect {
          described_class.new("fake-task-object")
        }.to raise_error(ArgumentError, "Incorrect argument type")
      end

      it "prevents service initialization if task is not in the :reviewing state" do
        invalid_task_states = %i(
          suggested_task
          accepted
          rejected
          doing
          completed
        )

        invalid_task_states.each do |state|
          task.state = state

          expect {
            described_class.new(task)
          }.to raise_error(ArgumentError, "Incorrect task state: #{state}")
        end
      end

      context "when task is fully funded" do
        let(:task_attributes) do
          { budget: 2_000_000, current_fund: 2_999_999, state: :reviewing }
        end

        it "allows service initialization" do
          expect {
            described_class.new(task)
          }.not_to raise_error
        end
      end

      context "when task is not fully funded" do
        let(:task_attributes) do
          { budget: 2000, current_fund: 1999, state: :reviewing }
        end

        it "prevents service initialization" do
          expect {
            described_class.new(task)
          }.to raise_error(ArgumentError, "Task fund level is too low and cannot be transfered")
        end
      end

      context "when task's budget is too low but it's fully funded" do
        let(:task_attributes) do
          { budget: 2000, current_fund: 2000, state: :reviewing }
        end

        it "prevents service initialization" do
          invalid_task = FactoryGirl.build(:task, :with_associations, :with_balance, task_attributes)
          expect {
            described_class.new(invalid_task)
          }.to raise_error(ArgumentError, "Task fund level is too low and cannot be transfered")
        end
      end

      context "when task's balance is enough" do
        let(:task_attributes) do
          { budget: 2_000_000, current_fund: 2_000_000, state: :reviewing }
        end

        it "allows service initialization" do
          expect {
            described_class.new(task)
          }.not_to raise_error
        end
      end
    end
  end
end
