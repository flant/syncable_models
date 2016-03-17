module SyncableModels::Controller
  extend ActiveSupport::Concern

  BATCH_COUNT = 50

  module ClassMethods
  def sync_for(subject, class_name: nil, sync_method: nil, fetch_method: nil)
    klass = class_name || subject.to_s.singularize.camelize
    klass = klass.constantize unless klass.is_a?(Class)

    sync_method = sync_method || "sync_#{subject}"
    fetch_method = fetch_method || "#{subject}"

    class_eval """
      def #{sync_method}
        set_synced #{klass.name}
      end

      def #{fetch_method}
        fetch #{klass.name}
      end
    """
  end
  end

  def fetch(klass)
    if params[:destination]
      count = params[:count].present? ? params[:count].to_i : BATCH_COUNT
      result = klass.not_synced(params[:destination]).limit(count).map(&:to_import_hash)
      render json: { status: 200, objects: result }
    else
      render_argument_error
    end
  end

  def set_synced(klass, id_key = :uuid)
    if params[:ids] && params[:destination]
      klass.where(id_key => params[:ids]).sync(params[:destination])
      render json: { status: 200 }
    else
      render_argument_error
    end
  end

  def render_argument_error
    return render json: { status: 400, message: 'Not enough arguments' }
  end
end
