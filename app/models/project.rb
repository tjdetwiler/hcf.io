class Project < ActiveRecord::Base
  has_many :source_files
  belongs_to :user
end
