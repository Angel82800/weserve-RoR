require 'rails_helper'

RSpec.describe NotificationsController do
  context 'did not sign in' do
    it 'redirects to sign in page' do
      get :index

      expect(response).to redirect_to(new_user_session_url)
    end
  end

  context 'signed in' do
    let(:user)  { create(:user, :confirmed_user) }

    before do
      sign_in(user)
    end

    describe '#index' do
      before do
        create(:notification, id: 111, user: user)
      end

      it 'retreives user\'s unread notifications' do
        create(:notification, id: 222, user: user)

        get :index

        notification_ids = assigns(:notifications).map(&:id)

        expect(notification_ids.count).to eq 2
        expect(notification_ids).to include 111
        expect(notification_ids).to include 222
      end

      it 'cannot retreives other people\s unread notifications' do
        create(:notification, id: 222)

        get :index

        notification_ids = assigns(:notifications).map(&:id)

        expect(notification_ids).to include 111
        expect(notification_ids).not_to include 222
      end

      it 'marks only shown notifications as read' do
        get :index

        notifications = assigns(:notifications).map(&:reload)
        notification = create(:notification, id: 222, user: user)

        expect(notifications[0].read?).to be true
        expect(notification.read?).to be false
      end

      it 'marks only user\'s notifications as read' do
        notification = create(:notification, id: 222)

        get :index

        notifications = user.notifications.reload

        expect(notifications[0].read?).to be true

        expect(notification.reload.read?).to be false
      end
    end

    describe '#load_older' do
      before do
        create(:notification, id: 111)
        create(:notification, id: 222, user: user)
        create(:notification, id: 333, user: user)
      end

      it 'loads only user\'s older notifications' do
        xhr :get, :load_older, first_notification_id: 333

        notification_ids = assigns(:notifications).map(&:id)

        expect(notification_ids).to include 222
        expect(notification_ids).not_to include 111
      end
    end

    describe '#destroy' do
      context 'delets only user\'s notification' do
        it 'deletes successfully' do
          create(:notification, user: user, id: 333)

          expect { xhr :delete, :destroy, id: 333 }.to change(user.notifications, :count).by(-1)
        end
      end

      context 'deletes unbelonging notification' do
        it 'does not delete the notification' do
          create(:notification, id: 444)

          expect { xhr :delete, :destroy, id: 444 }.not_to change(Notification, :count)
        end

        context 'notification not found' do
          it 'redirects user to root path' do
            create(:notification, id: 444)

            xhr :delete, :destroy, id: 444

            expect(response).to have_http_status(:not_found)
          end
        end
      end
    end
  end
end
