class Api::V1::MediawikiController < Api::V1::BaseController
  skip_before_action :verify_authenticity_token

  def page_edited
    begin
      request_payload = JSON.parse(request.body.read.tr("'", '"'))
    rescue
      return bad_request
    end
    return render json: { error_message: "Unauthorized" }, status: :unauthorized unless request_payload["secret"] == ENV['mediawiki_api_secret']
    return render json: { error_message: "Unknown type" }, status: :bad_request unless request_payload["type"] == "edit"

    data = request_payload["data"]
    page_name, editor_username = data["page_name"], data["editor_name"] if data

    send_emails(page_name, editor_username)
  end

  private

  def send_emails(page_name, editor_username)
    return bad_request unless page_name && editor_username
    # sub_page = page_name.split('/')[1] if page_name.include? '/'
    project_name = page_name.split('/')[0]

    editor = User.find_by!(username: get_search_data(editor_username))
    project = Project.find_by!(title: get_search_data(project_name))
    recipient_list = build_recipient_list(project) - [editor]
    project.add_team_member(editor)

    recipient_list.each do |recipient|
      mailer_params = { project_id: project.id, editor_id: editor.id,
                        receiver_id: recipient.id }
      if editor == project.leader
        ProjectMailer.project_text_edited_by_leader(mailer_params).deliver_later
      elsif project.is_approval_enabled?
        ProjectMailer.project_text_submitted_for_approval(mailer_params).deliver_later
      else
        ProjectMailer.project_text_edited(mailer_params).deliver_later
      end
    end
    render json: { status: "200 OK" }
  end

  def build_recipient_list(project)
    recipient_list = []
    recipient_list += project.proj_admins.map(&:user)
    recipient_list += project.team_members
    recipient_list += project.project_users.map(&:user)
    recipient_list.uniq!
    # the users should be followers to receive notifications
    recipient_list & project.followers
  end

  def bad_request
    render json: { error_message: "Bad request" }, status: :bad_request
  end

  def get_search_data(param)
    [param, param[0].downcase + param[1..-1]]
  end
end
