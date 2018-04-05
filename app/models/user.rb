class User < ApplicationRecord
  # Note that email must be case-insensitively unique.

  # Include default devise modules. Others available are:
  # :confirmable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable

  def active_for_authentication?
    super && disabled_at.nil?
  end

  def inactive_message
    disabled_at.nil? ? super : :banhammered
  end
end
