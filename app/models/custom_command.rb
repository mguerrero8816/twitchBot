class CustomCommand < ApplicationRecord
  validates :command, format: { with: /\A[A-Za-z0-9]+\z/ }, uniqueness: { case_sensitive: false, scope: :channel_id }
  validates :command, :response, presence: true
end
