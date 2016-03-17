module SyncableModels
  class ImportConfigGenerator < Rails::Generators::Base
    source_root(File.expand_path(File.dirname(__FILE__)))


    def copy_initializer_file
      copy_file 'templates/initializer.rb', 'config/initializers/syncable_models.rb'
    end
  end
end
