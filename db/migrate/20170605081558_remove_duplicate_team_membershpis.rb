class RemoveDuplicateTeamMembershpis < ActiveRecord::Migration
  # Removes duplicate team memberships (Team Leader used to be able to become Team Member as well)
  def change
    Project.all.each do |project|
      next unless project.team && project.team.team_members
      duplicate_users = project.team.team_members.select{ |e| project.team.team_members.to_a.count(e) > 1 }.uniq
      next if duplicate_users.blank?
      first_appearance = []
      project.team.team_memberships.each do |team_membership|
        next unless duplicate_users.include? team_membership.team_member
        if first_appearance.include? team_membership.team_member
          team_membership.destroy
        else
          first_appearance << team_membership.team_member
        end
      end
    end
  end
end
