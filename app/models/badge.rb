class Badge < ActiveRecord::Base
  # Enum attrs
  BUDGE_TYPES = [:donor]
  enum badge_type: BUDGE_TYPES

  # Relations
  belongs_to :user
  belongs_to :project

  # Scopes
  scope :project_badges, -> (project_id) { where(project_id: project_id) }
end
