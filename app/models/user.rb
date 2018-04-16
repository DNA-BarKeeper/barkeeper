class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :lab
  has_many :contig_searches
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :responsibilities

  validates_presence_of :email # necessary for devise

  enum role: [:guest, :user, :supervisor, :admin]
end
