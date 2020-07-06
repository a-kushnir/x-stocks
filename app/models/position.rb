class Position < ApplicationRecord

  belongs_to :user
  belongs_to :stock

  validates :user, presence: true
  validates :stock, presence: true, uniqueness: { scope: :user }

  def to_s
    stock&.to_s
  end

end
