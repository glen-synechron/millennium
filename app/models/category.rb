class Category < ActiveRecord::Base
  attr_accessible :name, :parent_id
  has_many :sub_categories
  acts_as_tree order: "name"
end
