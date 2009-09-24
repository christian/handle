class RFile < ActiveRecord::Base
  has_attached_file :file
  validates_attachment_presence :file
  validates_attachment_content_type :file, :content_type => ['image/jpeg', 'application/pdf', 'image/png', 'image/jpg', 'image/gif']
  
  ICONS = {'image/jpeg' => 'doc_types/icon_image.gif',
           'application/pdf' => 'doc_types/icon_pdf.gif',
           'image/jpg' => 'doc_types/icon_image.gif',
           'image/png' => 'doc_types/icon_image.gif',
           'image/gif' => 'doc_types/icon_image.gif'}
end
