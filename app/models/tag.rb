class Tag < ActiveRecord::Base
  attr_accessible :t_val
  belongs_to :post
end
