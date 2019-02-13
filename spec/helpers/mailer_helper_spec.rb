require 'rails_helper'

describe MailerHelper, type: :helper do
  # include MailerHelper
  let(:project) { FactoryGirl.create(:project, user: leader) }
  let(:leader) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }
  let(:other_user) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }
  let(:task) { FactoryGirl.create(:task, project: project, user: leader) }

  describe '#prep_mailjet_options' do
    subject { prep_mailjet_options(message_params) }
    let(:message_params) { {} }

    it "adds TemplateLanguage" do
      expect(subject['TemplateLanguage']).to be_truthy
    end

    it "adds AppPrefix when Variables are not present" do
      expect(subject['Variables']).to eq({"AppPrefix" => ENV['mailjet_subject_prefix']})
    end

    context "when Variables is present" do
      let(:message_params) { {"Variables" => { "ReceiverName" => "test" }} }

      it "adds AppPrefix when Variables are not present" do
        expect(subject["Variables"]["AppPrefix"]).to eq(ENV['mailjet_subject_prefix'])
      end
    end
  end

  describe '#mailjet_project_variables' do
    context "when project and task are nil" do
      subject { mailjet_project_variables(nil, nil) }
      it "returns empty hash" do
        expect(subject).to eq({})
      end
    end

    context "when project and task is presnt" do
      subject { mailjet_project_variables(project, task) }
      it "includes project variables" do
        expect(subject).to eq({ "ProjectTitle" => project.title,
                                "ProjectUrl" => project_url(project.id) })
      end
    end

    context "when only task is presnt" do
      subject { mailjet_project_variables(nil, task) }
      it "takes project from task returns variables" do
        expect(subject).to eq({ "ProjectTitle" => project.title,
                                "ProjectUrl" => project_url(project.id) })
      end
    end
  end

  describe '#mailjet_task_variables' do
    context "when task is nil" do
      subject { mailjet_task_variables(nil) }
      it "returns empty hash" do
        expect(subject).to eq({})
      end
    end
    context "when task is present" do
      subject { mailjet_task_variables(task) }
      it "takes value from title of task" do
        expect(subject).to eq({
                                "TaskTitle" => task.title,
                                "TaskUrl" => taskstab_project_url(project, tab: 'tasks', board: task.board_id, taskId: task.id)
                              })
      end
    end
  end

  describe '#mailjet_name_variables' do
    it "assigns the approver name" do
      expect(mailjet_name_variables(approver: other_user ))
        .to eq({
                 "ApproverName" => other_user.display_name,
               })
    end

    it "assigns the reviewer name" do
      expect(mailjet_name_variables(reviewer: other_user ))
        .to eq({
                 "ReviewerName" => other_user.display_name,
               })
    end

    it "assigns the user name" do
      expect(mailjet_name_variables(user: other_user ))
        .to eq({
                 "UserName" => other_user.display_name,
               })
    end

    it "assigns the assignee name" do
      expect(mailjet_name_variables(assignee: other_user ))
        .to eq({
                 "AssigneeName" => other_user.display_name,
               })
    end
  end

  describe "#user_locale" do
    context "when user is present" do
      context "and user's preferred language is set" do
        it "reuturns user's preferred locale" do
          leader.update(preferred_language: "fr")
          expect(user_locale(leader)).to eq(:fr)
        end
      end
      context "and user's preferred language is nil" do
        before do
          leader.update(preferred_language: nil)
        end

        context "when locale is default locale" do
          it "returns default locale" do
            expect(user_locale(leader)).to eq(I18n.default_locale)
          end
        end

        context "when locale is fr" do
          it "returns fr" do
            I18n.with_locale(:fr) do
              expect(user_locale(leader)).to eq(:fr)
            end
          end
        end
      end
    end

    context "when user is nil" do
      context "when locale is default locale" do
        it "returns default locale" do
          expect(user_locale(nil)).to eq(I18n.default_locale)
        end
      end

      context "when locale is fr" do
        it "returns fr" do
          I18n.with_locale(:fr) do
            expect(user_locale(nil)).to eq(:fr)
          end
        end
      end
    end
  end


  describe "#template_id" do
    before do
      instance_variable_set(:@virtual_path, "")
      @english = I18n.t(:mailjet_template_id, locale: "en")
      @french = I18n.t(:mailjet_template_id, locale: "fr")

      I18n.backend.store_translations("en", {mailjet_template_id: "123"})
      I18n.backend.store_translations("fr", {mailjet_template_id: "345"})
    end

    context "when locale is en" do
      it "reuturns translation in en" do
        allow_any_instance_of(MailerHelper).to receive(:user_locale) { :en }
        expect(template_id(leader)).to eq("123")
      end
    end

    context "and locale is fr" do
      it "reuturns translation in fr" do
        allow_any_instance_of(MailerHelper).to receive(:user_locale) { :fr }
        expect(template_id(leader)).to eq("345")
      end
    end

    after do
      I18n.backend.store_translations("en", {mailjet_template_id: @english})
      I18n.backend.store_translations("fr", {mailjet_template_id: @french})
    end
  end
end
