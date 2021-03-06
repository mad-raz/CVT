# == Schema Information
#
# Table name: torrents
#
#  id                   :uuid             not null, primary key
#  name                 :string
#  transmission_id      :integer
#  size                 :integer
#  checksum             :string
#  user_id              :uuid             indexed
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  torrent_file_name    :string
#  torrent_content_type :string
#  torrent_file_size    :integer
#  torrent_updated_at   :datetime
#
# Indexes
#
#  index_torrents_on_user_id  (user_id)
#

class Torrent < ApplicationRecord
  extend Memoist

  # Relations
  belongs_to :user, required: true

  has_attached_file :torrent

  # Validations
  validates :name, presence: true
  validates :transmission_id, presence: true
  validates :size, presence: true, numericality: { greater_than: 0 }
  validates :checksum, presence: true, uniqueness: { scope: :user_id }
  validates_attachment :torrent,
    presence: true,
    content_type: { content_type: 'application/x-bittorrent' }

  # Transmission Torrent Object
  def transmission
    torrent = Transmission::RPC::Torrent.find(transmission_id)
    fail NotFoundError, 'torrents.not_found' unless torrent
    torrent
  end
  memoize :transmission
end
