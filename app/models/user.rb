class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :journeys, dependent: :destroy
  has_many :routes, through: :journeys

  validates :email, presence: true, uniqueness: true

  # def carbon_savings_total
  #   journeys.joins(:route).sum(:carbon_saved_kg)
  # end
end
