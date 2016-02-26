Rails.application.routes.draw do

  mount SyncableModels::Engine => "/syncable_models"
end
