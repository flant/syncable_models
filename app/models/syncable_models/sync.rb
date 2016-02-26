module SyncableModels
  class Sync < ::ActiveRecord::Base
    self.table_name = "syncs"

    belongs_to :subject, polymorphic: true, inverse_of: :syncs

    validates :subject, :subject_type, :destination, presence: true

    scope :by_destination, ->(*d) { where(destination: d) }
  end
end
