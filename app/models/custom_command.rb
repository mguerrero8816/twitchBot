class CustomCommand < ApplicationRecord
  validates :command, format: { with: /\A[A-Za-z0-9]+\z/ }, uniqueness: { case_sensitive: false }
  validates :command, :response, presence: true
end
