class User < ApplicationRecord
  include ProjectRecord

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :lab
  has_many :contig_searches
  has_and_belongs_to_many :responsibilities

  validates_presence_of :email # Necessary for devise
  validates :projects, presence: true

  before_save :default_project

  enum role: [:guest, :user, :supervisor, :admin]

  def default_project
    self.default_project_id ||= projects&.first&.id
  end
end