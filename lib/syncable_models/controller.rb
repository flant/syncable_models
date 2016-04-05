module SyncableModels::Controller
  extend ActiveSupport::Concern

  BATCH_COUNT = 50

  module ClassMethods
    def sync_for(subject, id_key: :uuid, class_name: nil, sync_method: nil, fetch_method: nil)
      klass = class_name || subject.to_s.singularize.camelize
      klass = klass.constantize unless klass.is_a?(Class)

      sync_method = sync_method || "sync_#{subject}"
      fetch_method = fetch_method || "#{subject}"

      class_eval """
        def #{sync_method}
          set_synced #{klass.name}, :#{id_key.to_s}
        end

        def #{fetch_method}
          fetch #{klass.name}
        end
      """
    end

    def authorize_by_key(key=nil)
      define_method(:api_key){ key }
      before_action :do_authorize_by_key
    end
  end

  def fetch(klass)
    if params[:destination]
      count = params[:count].present? ? params[:count].to_i : BATCH_COUNT

      for_sync = klass.syncable_models_suitable(params[:destination])
                      .not_synced(params[:destination])
                      .limit(count)
                      .map(&:to_import_hash)
      count = count - for_sync.count

      for_destroy = SyncableModels::Sync
        .by_destination(params[:destination])
        .for_destroying
        .limit(count)
        .map(&:subject_external_id)

      render json: { status: 200, for_sync: for_sync, for_destroy: for_destroy }
    else
      render_argument_error
    end
  end

  def set_synced(klass, id_key)
    if params[:ids] && params[:destination]
      ids = params[:ids]

      destruction_syncs = SyncableModels::Sync
        .by_destination(params[:destination])
        .for_destroying
        .where(subject_external_id: ids)

      destruction_sync_ids = destruction_syncs.pluck(:subject_external_id).map(&:to_s)
      destruction_syncs.each(&:destroy)
      ids -= destruction_sync_ids

      klass.where(id_key => ids).sync(params[:destination])
      render json: { status: 200 }
    else
      render_argument_error
    end
  end

  def render_argument_error
    return render json: { status: 400, message: 'Not enough arguments' }
  end

  def do_authorize_by_key
    if params[:key] != api_key
      return render json: { status: 401, message: 'Unauthorized'}
    end
  end
end
