namespace :projects do
  desc "Sync full project descriptions from MediaWiki to PG & Solr"
  task sync_full_descriptions: :environment do
    ProjectDescriptionsUpdater.sync_all_projects
    Project.reindex
  end
end
