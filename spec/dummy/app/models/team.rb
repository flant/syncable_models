class Team < ActiveRecord::Base
  syncable id_key: :id

  validates :name, presence: true

  def self.from_import_hash(hash)
    object = Team.where(external_id: hash['id']).first || Team.new
    object.name = hash['name']
    object.external_id = hash['id']
    object.save
    object
  end
end
