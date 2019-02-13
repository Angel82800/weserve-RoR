class BadgeService
  class << self
    def assign_donor(project, user)
      return if project.nil?
      project.badges.find_or_create_by(user: user, badge_type: Badge.badge_types[:donor])
    end
  end
end
