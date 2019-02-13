module MailerHelper
  def prep_mailjet_options message_params
    # template language needs to be true while using the templates
    message_params.merge!({ "TemplateLanguage" => true })
    # adding AppPrefix variable for subject line on the supporting templates
    variables  = message_params["Variables"]
    if variables
      message_params["Variables"].merge!({ "AppPrefix" => ENV['mailjet_subject_prefix'] })
    else
      message_params["Variables"] = { "AppPrefix" => ENV['mailjet_subject_prefix'] }
    end
    message_params
  end

  def mailjet_project_variables(project, task = nil)
    project = project || task.try(:project)
    return {
      "ProjectTitle" => project.title,
      "ProjectUrl" => project_url(project.id)
    } if project
    {}
  end

  def mailjet_task_variables(task)
    return {
      "TaskTitle" => task.title,
      "TaskUrl" => taskstab_project_url(task.project, tab: 'tasks', board: task.board_id, taskId: task.id)
    } if task
    {}
  end

  def mailjet_name_variables(opts={})
    variables = {}
    # check for the user types and map variables
    %i(reviewee approver reviewer user assignee requester suggestor previous_leader new_leader admin).each do |key|
      variables["#{key.to_s.camelize}Name"] = opts[key].display_name if opts[key].present?
    end
    variables
  end

  # assigns variables based on the options provided
  def mailjet_variables(receiver, opts={})
    exclude_list = opts[:exclude] || []

    variables = {}
    variables.merge!(mailjet_name_variables(opts))
    # map receivername unless excluded
    variables["ReceiverName"] = receiver.display_name unless exclude_list.include?(:receiver_name)
    # task variables based on task title or task
    # use task title to avoid having project variables
    variables.merge!(mailjet_task_variables(opts[:task]))
    # project variables based on either project or task
    # unless exclude_project value is provided explicitly use project variables
    variables.merge!(mailjet_project_variables(opts[:project], opts[:task])) unless exclude_list.include?(:project)
    # merge the variables that are raw string
    # can also be used to override the variables that would be described above
    variables.merge!(opts[:additional_params] || {})
    variables
  end

  def format_params_for_mailjet(templateid, variables)
    {
      "TemplateID" => templateid,
      "Variables" => variables
    }
  end

  # gets the mailjet template id for current locale
  def template_id(user=nil)
    I18n.with_locale(user_locale(user)) do
      t('.mailjet_template_id')
    end
  end



  def user_locale user
    locale  = (user&.preferred_language || I18n.locale).to_s.to_sym
    I18n.available_locales.include?(locale) ? locale : I18n.default_locale
  end

  def mailjet_notification(receiver, opts={})
    variables = mailjet_variables(receiver, opts)
    message_params = format_params_for_mailjet(template_id(receiver), variables)
    mailjet_mail(receiver.email, message_params)
  end

  def currency_symbol
    ENV['symbol_currency']
  end
end
