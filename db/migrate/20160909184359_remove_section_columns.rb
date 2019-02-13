class RemoveSectionColumns < ActiveRecord::Migration
   def self.up
      Project.all.each do |p|
        p.section_details.create(title:'First Section Details', context: p.section1.to_s)
        p.section_details.create(title:'Second Section Details', context: p.section2.to_s)
      end
      remove_column :projects, :section1, :text
      remove_column :projects, :section2, :text
   end

   def self.down
     add_column :projects, :section1, :text
     add_column :projects, :section2, :text
     Project.all.each do |p|
       p.update_attributes(section1: p.section_details.first.try(:context), section2: p.section_details.last.try(:context))
     end
   end
end
