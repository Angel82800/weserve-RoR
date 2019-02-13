class Ability
  include CanCan::Ability
  include AbilityTask

  def initialize(user)
    initializeProjectsPermissions(user)
    initializeUsersPermissions(user)
    initializeMessagesPermissions(user)
    initializeProfileCommentsPermissions(user)
    initializeProjAdminPermissions(user)
    initializeTasksPermissions(user)
    initializeAdminRequestsPermissions(user)
    initializeApplyRequestsPermissions(user)
    initializeDoRequestsPermissions(user)
    initializeTeamMembershipsPermissions(user)
    initializeTaskAttachmentsPermissions(user)
    initializeBoardsPermissions(user)
    initializeTaxDeductionPermissions(user)
  end

  def initializeTaxDeductionPermissions(user)
    if user
      can [:download_tax_receipt, :edit, :update], TaxDeduction do |tax_deduction|
        user == tax_deduction.user
      end
    end
  end

  def initializeTeamMembershipsPermissions(user)
    if user
      can [:create, :update], TeamMembership do |team_membership|
        user.is_project_leader?(team_membership.team.project)
      end

      can [:destroy], TeamMembership do |team_membership|
        (user.is_project_leader?(team_membership.team.project) && team_membership.team_member != user) || (user.is_coordinator_for?(team_membership.team.project) && team_membership.role == 'teammate') || user.admin?
      end
    end
  end

  def initializeAdminRequestsPermissions(user)
    if user
      can [:create], AdminRequest
      can [:accept, :reject], AdminRequest do |admin_request|
        admin_request.project.user.id == user.id
      end
    end
  end

  def initializeApplyRequestsPermissions(user)
    if user
      can [:accept, :reject], ApplyRequest do |apply_request|
        can :manage_requests, apply_request.project
      end
    end
  end

  def initializeDoRequestsPermissions(user)
    if user
      can [:accept, :reject], DoRequest do |do_request|
        can? :manage_requests, do_request.project
      end
    end
  end

  def initializeProjectsPermissions(user)
    can [:read, :search_results, :user_search, :autocomplete_user_search,
         :taskstab, :show_project_team, :get_in, :index], Project

    if user
      can [:create, :discussions, :follow, :unfollow, :rate,
           :accept_change_leader, :reject_change_leader, :my_projects], Project

      can [:change_leader, :accept, :reject ], Project do |project|
        user.is_project_leader?(project)
      end

      can [:update, :revisions, :revision_action, :block_user, :unblock_user, :switch_approval_status, :rename_subpage], Project do |project|
        user.is_project_leader?(project) || user.is_lead_editor_for?(project)
      end

      can [:manage_requests, :rearrange_order_tasks, :rearrange_order_boards], Project do |project|
        user.is_project_leader_or_coordinator_or_admin?(project)
      end

      can :destroy, Project do |project|
        project.user_id == user.id || user.admin?
      end

      update_project_by_admin(user)
    end
  end

  def initializeUsersPermissions(user)
    can :show, User
    can :state, User
    if user
      can [:my_projects], User
      can [:update, :destroy, :my_wallet, :payout_method, :payout_details, :payout,
           :credit_card, :bank, :remove_external, :verify, :withdraw_method, :payout_external], User, :id => user.id
      if user.admin?
        can [:index, :update, :destroy], User
      end
    end
  end

  def initializeMessagesPermissions(user)
    if user
      can :manage, GroupMessage
    end
  end

  def initializeProfileCommentsPermissions(user)
    can :read, ProfileComment
    if user
      can :create, ProfileComment
      can [:destroy, :update], ProfileComment, :commenter_id => user.id
    end
  end

  def initializeProjAdminPermissions(user)
    if user
      can [:create, :destroy, :update], ProjAdmin do |proj_admin|
        proj_admin.project.user.id == user.id
      end
    end
  end

  def initializeTasksPermissions(user)
    can :read, Task

    if user
      can :create_task_comment, Task

      can :destroy_task_comment, Task if user.admin?

      can :create, Task do |task|
        create_task(user, task)
      end

      update_task(user)

      change_state_task(user)

      can :create_or_destroy_task_attachment, Task do |task|
        user.is_coordinator_leader_owner?(task) || user.is_task_team_member?(task) || user.admin?
      end

      can :remove_member, Task do |task|
        remove_member_task(user, task)
      end

      can :destroy, user.admin?
    end
  end

  def initializeTaskAttachmentsPermissions(user)
    if user
      can [:create, :destroy], TaskAttachment do |task_attachment|
        user.is_coordinator_leader_owner?(task_attachment.task) || user.is_task_team_member?(task_attachment.task) || user.admin?
      end
    end
  end

  def initializeBoardsPermissions(user)
    can [:index, :show], Board

    if user
      can [:create, :update], Board do |board|
        user.is_project_leader_or_coordinator_or_admin?(board.project)
      end
      can [:destroy], Board do |board|
        user.is_project_leader_or_coordinator_or_admin?(board.project) && (board.project.boards.size > 1)
      end
    end
  end

  def update_task(user)
    can :update, Task do |task|
      leader_or_coordinator_or_admin_can_update_task(task, user) || user.suggested_task_owner?(task)
    end

    can :update_task_in_progress, Task do |task|
      user.is_project_leader_or_coordinator_or_admin?(task.project)
    end

    can [:update_budget, :update_deadline, :destroy], Task do |task|
      task.not_any_funding? && can?(:update, task)
    end

    can :update_budget_task, Task do |task|
      (user.is_coordinator_leader_owner?(task) || user.admin?) && task.not_any_funding?
    end

    can :update_deadline, Task do |task|
      update_deadline_task(user, task)
    end

    can :back_funding, Task do |task|
      reviewing_or_doing_task(task) && user.is_project_leader_or_coordinator_or_admin?(task.project)
    end
  end

  def change_state_task(user)
    can :accept, Task do |task|
      accept_task(user, task)
    end

    can :reject, Task do |task|
      reject_task(user, task)
    end

    can :reviewing, Task do |task|
      reviewing_task(user, task)
    end

    can :completed, Task do |task|
      completed_task(user, task)
    end

    can :doing, Task do |task|
      doing_task(user, task)
    end

    can :back_reviewing, Task do |task|
      back_reviewing_task(user, task)
    end

    can :incomplete, Task do |task|
      incomplete_task(user, task)
    end

    can :back_doing, Task do |task|
      back_doing_task(user, task)
    end
  end

  def update_project_by_admin(user)
    can [:archived, :update, :revisions, :revision_action, :block_user, :unblock_user, :switch_approval_status, :archive], Project if user.admin?

    can [:change_leader_by_admin], Project do |project|
      user.is_project_leader_or_admin?(project)
    end

    can [:change_user_role], Project if user.admin?

    can :cancel, Task do |task|
      reviewing_or_doing_task(task) && task_assignee_or_admin(user, task)
    end
    
    can [:add_assignee, :remove_assignee], Task if user.admin?
  end
end
