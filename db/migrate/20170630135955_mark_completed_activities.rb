class MarkCompletedActivities < ActiveRecord::Migration
  # When a task was completed his assignments weren't marked as completed - so the users 'completed tasks' count didn't change
  # This migration marks all of the completed tasks assignments as completed
  def change
    Task.all.each do |task|
      next unless task.completed?
      task.assignments.each do |assignment|
        next unless assignment.completed?
        assignment.complete!
      end
    end
  end
end
