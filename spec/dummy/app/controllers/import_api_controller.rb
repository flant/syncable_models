class ImportApiController < ActionController::Base
  include SyncableModels::Controller

  sync_for :projects
  sync_for :teams, id_key: :id
end
