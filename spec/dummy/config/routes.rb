Rails.application.routes.draw do

  namespace 'import_api' do
    get 'projects'
    get 'sync_projects'
    get 'teams'
    get 'sync_teams'
  end

  mount SyncableModels::Engine => "/syncable_models"
end
