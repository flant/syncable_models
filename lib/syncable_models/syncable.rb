require 'active_support'

module SyncableModels
  module Syncable
    def syncable(options = {})
      options.assert_valid_keys(
        :id_key
      )

      class_attribute :syncable_models_id_key
      self.syncable_models_id_key = options[:id_key] || :uuid

      include SyncableModels::ActiveRecord
    end
  end
end

ActiveSupport.on_load :active_record do
  ActiveRecord::Base.send :extend, SyncableModels::Syncable
end
