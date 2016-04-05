require 'active_support'

module SyncableModels
  module Syncable
    def syncable(options = {})
      options.assert_valid_keys(:id_key, :scope, :conditions)

      class_attribute :syncable_models_id_key
      class_attribute :syncable_models_scope
      class_attribute :syncable_models_conditions

      self.syncable_models_id_key = options[:id_key] || :uuid
      self.syncable_models_scope = options[:scope] || nil
      self.syncable_models_conditions = options[:conditions] || {}

      include SyncableModels::ActiveRecord
    end

    def syncable_models_suitable(destination)
      result = syncable_models_scope? ? self.send(syncable_models_scope) : self

      if syncable_models_conditions[destination].present?
        result = syncable_models_conditions[destination].call
      end

      result
    end
  end
end

ActiveSupport.on_load :active_record do
  ActiveRecord::Base.send :extend, SyncableModels::Syncable
end
