class Stock < ApplicationRecord

  has_one :company, dependent: :destroy
  has_many :company_peers, dependent: :destroy

  before_validation :upcase_symbol
  validates :symbol, presence: true, uniqueness: true

  after_save :update_company_peer_refs
  before_destroy :destroy_company_peer_refs

  def to_s
    symbol
  end

  private

  def upcase_symbol
    self.symbol = symbol.upcase
  end

  def update_company_peer_refs
    return unless saved_change_to_symbol?

    destroy_company_peer_refs
    CompanyPeer.where(peer_symbol: symbol).each do |peer|
      peer.update(peer_stock_id: id)
    end
  end

  def destroy_company_peer_refs
    CompanyPeer.where(peer_stock_id: id).each do |peer|
      peer.update(peer_stock_id: nil)
    end
  end
end
