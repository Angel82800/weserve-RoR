# Class is responsible for synchronization of projects' full descriptions
# from MediaWiki to PG
#
# Since there are tons of HTTP calls to MediaWiki we cannot add it to usual
# `searchable` sunspot's DSL in `Project` model, since then it will be called
# after every ActiveRecord callback and we'll have lots of not-needed HTTP
# calls to MediaWiki, which in turn, can slow down our logic with `Project`
# model.
class ProjectDescriptionsUpdater
  BATCH_SIZE = 100

  class << self
    def sync_all_projects
      fetch_batches do |batch|
        batch.each { |project| sync_project(project) }
      end
    end

    def sync_project(project)
      full_project_description = project.get_latest_revision
      project.update_attribute(:full_description, full_project_description)
    end

    private
    def fetch_batches
      Project.find_in_batches(batch_size: BATCH_SIZE) { |batch| yield batch }
    end
  end
end
