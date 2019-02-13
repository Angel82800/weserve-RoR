class ProjAdmin < ActiveRecord::Base
  include AASM

  belongs_to :project
  belongs_to :user

  validates_uniqueness_of :user_id, :scope => :project_id

  aasm :column => 'state', :whiny_transitions => false do
    state :pending
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
