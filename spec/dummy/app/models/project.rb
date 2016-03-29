class Project < ActiveRecord::Base
  syncable

  validates :name, :uuid, presence: true

  def self.from_import_hash(hash)
    object = Project.where(external_id: hash['uuid']).first || Project.new(uuid: SecureRandom.uuid, external_id: hash['uuid'])
    object.name = hash['name']
    object.external_id = hash['uuid']
    object.save
  end
end
