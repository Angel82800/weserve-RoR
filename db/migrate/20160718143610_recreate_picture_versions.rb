class RecreatePictureVersions < ActiveRecord::Migration
  def change
    Project.find_each do |user|
      user.picture.try(:recreate_versions)
    end
  end
end
