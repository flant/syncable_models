require 'faraday'
load 'tasks/syncable_models.rake'

module SyncableModels
  module Importer
    class Import
      attr_accessor :name, :api_url, :api_key, :destination, :interval, :timeout
      attr_reader :models

      def initialize(name)
        @name = name.to_s
        @models = {}
        @interval = 5.minutes
        @timeout = 10.seconds
      end

      def import_model(class_name, args = {})
        class_name = class_name.to_s if class_name.is_a?(Class)
        fetch_path = args[:fetch_path] || class_name.underscore.pluralize
        sync_path = args[:sync_path] || "sync_" + class_name.underscore.pluralize
        api_id_key = args[:api_id_key] || :uuid
        external_id_column = args[:external_id_column] || :external_id

        @models[class_name] = {
          fetch_path: fetch_path,
          sync_path: sync_path,
          api_id_key: api_id_key,
          external_id_column: external_id_column
        }
      end

      def api_url
        @api_url[-1] == '/' ? @api_url : @api_url + "/"
      end

      def params_with_api_key(params)
        params.merge!(key: api_key) if api_key
        params
      end

      def import(model_names=[])
        model_names = [model_names] unless model_names.is_a?(Array)
        model_names.map!(&:to_s)
        selected_models = model_names.any? ?
          @models.select{ |k, v| k.in? model_names } :
          @models

        selected_models.each do |model_name, params|
          puts "[SyncableModels::Importer] Importing #{model_name.underscore.pluralize}..."

          next if model_names.any? && !model_name.in?(model_names)

          response = fetch_request(params)

          if response.success?
            response = JSON.parse(response.body)
            if response["status"].to_i == 401
              puts "[SyncableModels::Importer] Wrong api key!"
            end

            synced_ids = []

            synced_ids += sync_update model_name, params, response['for_sync']
            synced_ids += sync_destroy model_name, params, response['for_destroy']

            sync_request(params, synced_ids) if synced_ids.any?
          end
        end
      end

      def fetch_request(params)
        conn = Faraday.new(url: api_url + params[:fetch_path])
        conn.get '', params_with_api_key(destination: destination)
      end

      def sync_request(params, ids)
        conn = Faraday.new(url: api_url + params[:sync_path])
        conn.get '', params_with_api_key(destination: destination, ids: ids)
      end

      def sync_update(model_name, params, objects)
        synced_ids = []

        if objects
          klass = model_name.constantize

          objects.each do |o|
            id = o[params[:api_id_key].to_s]
            result = klass.from_import_hash(o)
            puts "[SyncableModels::Importer] Importing #{model_name} (external_id=#{id}): #{ sync_result_as_string(result) }"
            synced_ids << id if result
          end
        end

        synced_ids
      end

      def sync_result_as_string(result)
        if result.respond_to?(:valid?) && result.respond_to?(:errors)
          result.valid? ? 'OK' : "FAIL: #{result.errors.try(:full_messages).try { |r| r.join(', ') }}"
        else
          result ? 'OK' : 'FAIL'
        end
      end

      def sync_destroy(model_name, params, ids)
        synced_ids = []

        if ids
          klass = model_name.constantize

          ids.each do |id|
            result = klass.where(params[:external_id_column].to_s => id).first.try(:destroy)
            puts "[SyncableModels::Importer] Destroying #{model_name} (external_id=#{id}): #{ result ? 'OK' : 'FAIL' }"
            synced_ids << id if result
          end
        end

        synced_ids
      end
    end

    mattr_accessor :imports
    @@imports = []

    def self.config
      yield self
    end

    def self.add_import(name)
      import = Import.new name
      yield import
      @@imports << import
    end

    def self.find_import(name)
      @@imports.detect{ |i| i.name == name.to_s }
    end

    def self.import_all
      @@imports.each(&:import)
    end
  end
end
