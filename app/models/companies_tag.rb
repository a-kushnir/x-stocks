class CompaniesTag < ApplicationRecord

  belongs_to :company
  belongs_to :tag

  validates :company, presence: true
  validates :tag, presence: true

end
