class Board < ActiveRecord::Base
  default_scope {order(:created_at)}

  attr_accessor :skip_title_validate

  belongs_to :project
  has_many :tasks, -> {order(created_at: :desc)}, dependent: :destroy

  validates :title, presence: true

  acts_as_paranoid

  def self.default_with_tasks(tasks)
    new(title:
      I18n.t('activerecord.board.default_title'),
      tasks: tasks
    )
  end
end
