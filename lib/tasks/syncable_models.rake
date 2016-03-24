# desc "Explaining what the task does"

def prepare_models(models)
  return unless models
  models.split(',').map(&:camelize)
end

namespace :syncable_models do
  task import: :environment do
    models = prepare_models(ENV['MODELS']) || []

    if import = SyncableModels::Importer.find_import(ENV['NAME'])
      import.import models
    else
      puts "Import #{ENV['NAME']} was not found..."
    end
  end
end
