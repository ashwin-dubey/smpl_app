class ApplicationRecord < ActiveRecord::Base
  include CurrentRequest
  self.abstract_class = true
  
end
