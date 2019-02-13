class SectionDetail < ActiveRecord::Base
  include Discussable

  attr_accessor :discussed_context, :discussed_title

  belongs_to :project
  belongs_to :parent, class_name: 'SectionDetail', foreign_key: 'parent_id'
  has_many :childs, class_name: 'SectionDetail', foreign_key: 'parent_id', dependent: :nullify

  delegate :can_update?, to: :project, allow_nil: true

  scope :of_parent, ->(p){ p ? p.childs : where(parent_id: nil)}
  scope :ordered, ->{order(:order,:title)}
  scope :completed, ->{where.not(context: '').where.not(title: '')}

  def completed?
    self.title.present? && self.context.present?
  end

  def discussed_title= value
    if can_update?
      self.send(:write_attribute, 'title', value)
    else
      unless value == self.title.to_s
        Discussion.find_or_initialize_by(discussable:self, user_id: User.current_user.id, field_name: 'title').update_attributes(context: value)
      end
    end
  end

  def discussed_title
    can_update? ?
        self.send(:read_attribute, 'title') :
        discussions.of_field('title').of_user(User.current_user).last.try(:context) || self.send(:read_attribute, 'title')
  end

  def discussed_context= value
    if can_update?
      self.send(:write_attribute, 'context', value)
    else
      unless value == self.context.to_s
        Discussion.find_or_initialize_by(discussable:self, user_id: User.current_user.id, field_name: 'context').update_attributes(context: value)
      end
    end
  end

  def discussed_context
    can_update? ?
        self.send(:read_attribute, 'context') :
        discussions.of_field('context').of_user(User.current_user).last.try(:context) || self.send(:read_attribute, 'context')
  end

end
