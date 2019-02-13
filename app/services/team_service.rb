class TeamService
  class << self
    def add_admin_to_project(project, user)
      add_team_member(project.team, user, TeamMembership.roles[:admin])
    end

    def add_team_member(team, member, role)
      TeamMembership.find_or_create_by(
        team_member: member,
        team: team,
        role: role
      )
    end
  end
end
