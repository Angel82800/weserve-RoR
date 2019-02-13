module TaskDetailHelper
	def get_link_task_doing(task)
		task.not_fully_funded_or_less_teammembers? ? "javascript:void(0)" : doing_task_path(task.id)
	end

	def present_tooltip_start_button(task)
		data_toggle = nil
		title = nil
		if task.not_fully_funded_or_less_teammembers?
			data_toggle = "tooltip"
			title = t('projects.task_details.task_cannot_start_tooltip')
		end
		[data_toggle, title]
	end
end