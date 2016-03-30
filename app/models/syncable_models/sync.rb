module SyncableModels
  class Sync < ::ActiveRecord::Base
    self.table_name = "syncs"

    belongs_to :subject, polymorphic: true, inverse_of: :syncs

    validates :subject, :subject_type, :destination, presence: true

    scope :by_destination, ->(*d) { where(destination: d) }
    scope :for_destroying, ->{ where(subject_destroyed: true) }

    before_save do
      self.subject_external_id = subject.syncable_models_external_id
    end

    def subject
      super || begin
        subject_klass = subject_type.constantize
        subject_klass.where(subject_klass.syncable_models_id_key => subject_external_id).first
      end
    end
  end
end
