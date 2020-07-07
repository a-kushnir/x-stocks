class CompanyPeer < ApplicationRecord

  belongs_to :stock
  belongs_to :peer_stock, class_name: 'Stock', optional: true

  validates :stock, presence: true
  validates :peer_symbol, presence: true, uniqueness: { scope: :stock }

  def to_s
    peer_symbol
  end

end
