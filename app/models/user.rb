class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  before_save :generate_api_key

  def regenerate_api_key!
    self.api_key = Devise.friendly_token
    self.save!
  end

  private

  def generate_api_key
    self.api_key ||= Devise.friendly_token if User.column_names.include?(:api_key)
  end
end
