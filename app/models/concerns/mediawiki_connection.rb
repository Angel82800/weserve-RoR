# frozen_string_literal: true
module MediawikiConnection
  extend ActiveSupport::Concern

  included do
    # MediaWiki API - Page Read
    def page_read(username = nil)
      parsed_result = username.blank? ? get(:read) : get(:read, user: username)
      return nil if parsed_result.blank?
      return { 'status' => 'error' } if parsed_result['error']
      content = results_to_hash(parsed_result)
      content["subpages"] = []
      return content unless parsed_result["response"]["subpages"]
      parsed_result["response"]["subpages"].each do |subpage|
        subpage_parsed_result = username.blank? ? get(:read, page: subpage["full_title"]) : get(:read, user: username, page: subpage["full_title"])
        content["subpages"] << {
                                 "id" => subpage["id"],
                                 "title" => subpage["title"],
                                 "full_title" => subpage["full_title"] ,
                                 "html" => results_to_hash(subpage_parsed_result)["html"]
                                }
      end
      content
    end

    # Returns page info requested multiple times in projects and tasks controllers
    def page_info(user)
      result = user ? page_read(user.username) : page_read(nil)
      if result && result["status"] == 'success'
        return result["html"], result["subpages"], result["is_blocked"]
      end
      return '', [], 0
    end

    # MediaWiki API - Page Create or Write
    def page_write(user, content)
      post(:write, { content: content }, user: user.username)
        .try(:[], 'response').try(:[], 'code')
    end

    # MediaWiki API - Subpage Create or Write 
    def subpage_write(user, content, subpage)
      post(:write_subpage, { content: content }, user: user.username, sub_page: subpage.tr(' ', '_'))
        .try(:[], 'response').try(:[], 'code')
    end

    # MediaWiki API - Change subpage title
    def subpage_rename(user, subpage_old_title, subpage_new_title)
      username = user.is_a?(User) ? user.username : user
      project_name = set_project_name(wiki_page_name, title)

      new_title = "#{project_name}/#{subpage_new_title}".tr(' ', '_')
      old_title = "#{project_name}/#{subpage_old_title}".tr(' ', '_')

      get(:move, user: username, page: old_title, page_new: new_title)
          .try(:[], 'response').try(:[], 'code')
    end

    # MediaWiki API - Get latest revision
    def get_latest_revision
      revision = get_revision(get_history.try(:[], 0).try(:[], 'id'))
      revision.try(:[], 'content')
    end

    # MediaWiki API - Get history
    def get_history
      get(:history).try(:[], 'response')
    end

    # MediaWiki API - Read subpage
    def read_subpage(full_name)
      get(:read, page: full_name).try(:[], 'response')
    end

    # MediaWiki API - Get revision
    def get_revision(revision_id)
      get(:revision, revision: revision_id).try(:[], 'response')
    end

    # MediaWiki API - Get revision author
    def get_revision_author(revision_id)
      r = get_revision(revision_id)
      if r
        username = r["author"][0].downcase + r["author"][1..-1]
        User.find_by_username(username) || User.find_by_username(r["author"])
      end
    end

    # MediaWiki API - Approve Revision by id
    def approve_revision(revision_id)
      get(:approve, revision: revision_id).try(:[], 'response').try(:[], 'code')
    end

    # MediaWiki API - Unapprove Revision by id
    def unapprove_revision(revision_id)
      get(:unapprove, revision: revision_id).try(:[], 'response').try(:[], 'code')
    end

    # MediaWiki API - Unapprove approved revision
    def unapprove
      get(:unapprove).try(:[], 'response').try(:[], 'code')
    end

    # MediaWiki API - Block user
    def block_user(username)
      get(:block, user: username).try(:[], 'response').try(:[], 'code')
    end

    # MediaWiki API - Unblock user
    def unblock_user(username)
      get(:unblock, user: username).try(:[], 'response').try(:[], 'code')
    end

    # MediaWiki API - Change page title
    def rename_page(username, old_title)
      new_title = set_project_name(wiki_page_name, title)
      old_title = old_title.tr(' ', '_')
      get(:move, user: username, page: old_title, page_new: new_title)
        .try(:[], 'response').try(:[], 'code')
    end

    # MediaWiki API - Grant permissions to user
    def grant_permissions(username)
      get(:grant, user: username).try(:[], 'response').try(:[], 'code')
    end

    # MediaWiki API - Revoke permissions from user
    def revoke_permissions(username)
      get(:revoke, user: username).try(:[], 'response').try(:[], 'code')
    end

    # MediaWiki API - archive (safe delete) a page
    def archive(username)
      get(:delete, user: username).try(:[], 'response').try(:[], 'code')
    end

    # MediaWiki API - un-archive (restore) a page
    def unarchive(username = User.current_user)
      get(:restore, user: username).try(:[], 'response').try(:[], 'code')
    end

    private

    def set_project_name(wiki_page_name, title)
      wiki_page_name.present? ? wiki_page_name.tr(' ', '_') : title.strip.tr(' ', '_')
    end

    def get(action, params = {})
      base_request(action, params) do |url, opts|
        RestClient.get(url, opts)
      end
    end

    def post(action, params = {}, data = {})
      base_request(action, params) do |url, opts|
        RestClient.post(url, data, opts)
      end
    end

    def base_request(action, params = {})
      return nil unless Rails.configuration.mediawiki_session
      params[:action] ||= :weserve
      params[:method] ||= action
      params[:format] ||= :json
      params[:page] ||= set_project_name(wiki_page_name, title)

      base_url = "#{Project.load_mediawiki_api_base_url}api.php?#{to_url(params)}"
      Rails.logger.debug "request to wiki: #{base_url}"
      result = yield base_url, cookies: Rails.configuration.mediawiki_session
      Rails.logger.debug "Received response from wiki #{result}"
      JSON.parse(result.body)
    rescue => error
      Rails.logger.debug "Failed to call Mediawiki api #{error}"
      nil
    end

    def to_url(params)
      URI.escape(params.collect { |k, v| "#{k}=#{v}" }.join('&')) if params
    end

    def results_to_hash(parsed_result)
      {}.tap do |content|
        content['revision_id'] = parsed_result['response']['revision_id']
        content['non-html'] = parsed_result['response']['content']
        content['html'] = parsed_result['response']['contentHtml']
        content['is_blocked'] = parsed_result['response']['is_blocked']
        content['status'] = 'success'
      end
    end
  end

  class_methods do
    # Load MediaWiki API Base URL from application.yml
    def load_mediawiki_api_base_url
      ENV['mediawiki_api_base_url']
    end
  end
end
