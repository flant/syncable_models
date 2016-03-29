module SyncableModels::ActiveRecord
  extend ActiveSupport::Concern

  included do
    has_many :syncs,
      as: :subject,
      inverse_of: :subject,
      class_name: ::SyncableModels::Sync,
      dependent: :nullify

    after_update :clear_syncs_on_update
    after_destroy :set_syncs_destroyed

    scope :synced, ->(d){ joins(:syncs).where(syncs: { destination: d }) }
    scope :not_synced, ->(d) do
      where.not(id: ::SyncableModels::Sync.by_destination(d).where(subject_type: self.name).pluck(:subject_id))
    end
  end

  module ClassMethods
    def sync(destination)
      self.all.each{ |e| e.sync(destination) }
    end
  end

  def synced?(destination)
    syncs.where(destination: destination).exists?
  end

  def sync(destination)
    syncs.create(destination: destination) unless synced?(destination)
  end

  def clear_syncs(destination = nil)
    (destination ? syncs.by_destination(destination) : syncs).destroy_all
  end

  def syncable_models_external_id
    self.send(self.class.syncable_models_id_key)
  end

  def clear_syncs_on_update
    clear_syncs
  end

  def set_syncs_destroyed
    SyncableModels::Sync.where(subject_external_id: self.syncable_models_external_id)
      .update_all(subject_destroyed: true)
  end

  def to_import_hash
    attributes
  end
end
