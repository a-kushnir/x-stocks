class Company < ApplicationRecord

  belongs_to :stock
  has_many :companies_tags
  has_many :tags, through: :companies_tags

  validates :stock, presence: true, uniqueness: true

  def to_s
    company_name
  end

end
