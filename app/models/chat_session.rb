class ChatSession < ActiveRecord::Base
  belongs_to :requester, class_name: 'User'
  belongs_to :receiver, class_name: 'User'

  validates :requester, presence: true
  validates :receiver, presence: true

  before_create :initial_values

  def self.find_by_channel(name)
    find_by_uuid(name.gsub(/^private-/, '')) if name.present?
  end

  def self.for_users(*users)
    if users.length > 1
      permuted = users.permutation(2).to_a.flatten
      query = users.map do
        '(requester_id = ? AND receiver_id = ?)'
      end.join(' OR ')
      where(query, *permuted)
    else
      where('requester_id = ? OR receiver_id = ?', users, users)
    end
  end

  def initial_values
    if uuid.blank?
      loop do
        new_uuid = SecureRandom.uuid
        if ChatSession.find_by_uuid(new_uuid).blank?
          self.uuid = new_uuid
          break
        end
      end
    end
    self.status ||= 'pending'
  end

  def participating_user?(user)
    requester == user || receiver == user
  end
end
