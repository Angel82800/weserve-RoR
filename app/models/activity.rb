class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :targetable, polymorphic: true

  def self.for_task_and_comments(task)
    where('(targetable_type = ? AND targetable_id = ?) OR '\
          '(targetable_type = ? AND targetable_id IN (?))', 'Task', task.id,
          'TaskComment', task.task_comments.collect(&:id))
      .order('created_at DESC')
  end

  def archived_targetable
    targetable_type.constantize.only_deleted.find_by(id: targetable_id)
  end

  %w(created edited deleted incomplete).each do |action_name|
    define_method("#{action_name}?") do
      action == action_name
    end
  end
end
