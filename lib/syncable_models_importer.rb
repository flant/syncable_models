require 'faraday'

module SyncableModelsImporter
  class Import
    attr_accessor :api_url, :destination
    attr_reader :models

    def initialize
      @models = {}
    end

    def import_model(class_name, args = {})
      class_name = class_name.to_s if class_name.is_a?(Class)
      fetch_path = args[:fetch_path] || class_name.underscore.pluralize
      sync_path = args[:sync_path] || "sync_" + class_name.underscore.pluralize
      id_key = args[:id_key] || :uuid
      @models[class_name] = {
        fetch_path: fetch_path,
        sync_path: sync_path,
        id_key: id_key
      }
    end

    def api_url
      @api_url[-1] == '/' ? @api_url : @api_url + "/"
    end

    def import
      @models.each do |model_name, params|
        fetch_url = self.api_url + params[:fetch_path]
        sync_url = self.api_url + params[:sync_path]

        conn = Faraday.new(url: fetch_url)
        response = conn.get '', destination: self.destination

        if response.success?
          response = JSON.parse(response.body)

          if response['objects'] && response['objects'].count > 0
            klass = model_name.constantize
            synced_ids = []

            response['objects'].each do |o|
              result = klass.from_import_hash(o)
              synced_ids << o[params[:id_key].to_s] if result
            end

            if synced_ids.any?
              conn = Faraday.new(url: sync_url)
              response = conn.get '', destination: self.destination, ids: synced_ids
            end
          end
        end
      end
    end
  end

  mattr_accessor :imports
  @@imports = []

  def self.config
    yield self
  end

  def self.add_import
    import = Import.new
    yield import
    @@imports << import
  end

  def self.import
    @@imports.each &:import
  end
end
