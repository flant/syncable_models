module SyncableModels::ActiveRecord
  extend ActiveSupport::Concern

  included do
    has_many :syncs, as: :subject, inverse_of: :subject, class_name: ::SyncableModels::Sync

    after_update :clear_syncs_on_update

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
    self.syncs.where(destination: destination).exists?
  end

  def sync(destination)
    self.syncs.create(destination: destination) unless self.synced?(destination)
  end

  def clear_syncs(destination = nil)
    syncs = destination ? self.syncs.by_destination(destination) : self.syncs
    syncs.destroy_all
  end

  def clear_syncs_on_update
    self.clear_syncs
  end

  def to_import_hash
    self.attributes
  end
end
