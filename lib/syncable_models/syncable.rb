require 'active_support'

module SyncableModels
  module Syncable
    def syncable(options = {})
      options.assert_valid_keys(:id_key, :scope)

      class_attribute :syncable_models_id_key
      class_attribute :syncable_models_scope

      self.syncable_models_id_key = options[:id_key] || :uuid
      self.syncable_models_scope = options[:scope] || nil

      include SyncableModels::ActiveRecord
    end

    def syncable_models_suitable
      syncable_models_scope? ? self.send(syncable_models_scope) : self
    end
  end
end

ActiveSupport.on_load :active_record do
  ActiveRecord::Base.send :extend, SyncableModels::Syncable
end
