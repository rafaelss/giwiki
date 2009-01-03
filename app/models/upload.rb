class Upload < ActiveRecord::Base
  belongs_to :user
  validates_presence_of         :title
  validates_presence_of         :tags
#  validates_attachment_presence :upload

  has_attached_file :upload,
    :styles => { :medium => "300x400>", :thumb => "48x48#"},
    :path => ":rails_root/public/uploads/:style/:id/:basename.:extension",
    :url => "/uploads/:style/:id/:basename.:extension"

end
