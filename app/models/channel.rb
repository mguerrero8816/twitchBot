class Channel < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  after_create :update_email
  validates_uniqueness_of :name, case_sensitive: false

  def update_email
    self.update_attribute('email', "#{name}@test.com")
  end

  def email_required?
    false
  end

  def email_changed?
    false
  end
end
