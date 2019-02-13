class ProjectEdit < ActiveRecord::Base
  include AASM

  belongs_to :user
  belongs_to :project

  # Paranoia delete
  acts_as_paranoid

  aasm :whiny_transitions => false do
    state :pending, :initial => true
    state :accepted
    state :rejected

    event :accept do
      transitions :from => :pending, :to => :accepted
    end

    event :reject do
      transitions :from => :pending, :to => :rejected
    end
  end
end
