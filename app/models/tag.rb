class Tag < ApplicationRecord

  has_many :companies_tags
  has_many :companies, through: :companies_tags

  validates :name, presence: true, uniqueness: true

  def to_s
    name
  end

end
