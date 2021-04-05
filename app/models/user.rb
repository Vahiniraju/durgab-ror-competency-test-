class User < ApplicationRecord
  ############################################################################################
  ## PeterGate Roles                                                                        ##
  ## The :user role is added by default and shouldn't be included in this list.             ##
  ## The :root_admin can access any page regardless of access settings. Use with caution!   ##
  ## The multiple option can be set to true if you need users to have multiple roles.       ##
  petergate(roles: %i[admin editor], multiple: false) ##
  ############################################################################################

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  validates :name, presence: true

  has_many :articles

  scope :unarchived, -> { where(archived: false) }

  after_commit :archive_articles, if: -> { archived }

  def set_password
    hex = SecureRandom.hex(10)
    self.password = self.password_confirmation = hex
  end

  def unscoped_articles
    Article.unscoped.where(user_id: id)
  end

  private

  def archive_articles
    articles.update_all(archived: true)
  end
end
