class Shop < ActiveRecord::Base
  has_many :templates, :class_name => "PrintTemplate"
end
