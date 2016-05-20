require 'rails_helper'

module SyncableModels
  module Importer
    class TestResponse
      def initialize(response)
        @response = response
      end

      def body
        @response.to_json
      end

      def success?
        true
      end
    end
  end
end

def set_fetch_request_response(response)
  SyncableModels::Importer::Import
    .send(:define_method,
          :fetch_request,
          Proc.new{ |params| SyncableModels::Importer::TestResponse.new(response) })
end

RSpec.describe SyncableModels::Importer::Import, type: :model do
  before :all do
    SyncableModels::Importer::Import.send(:define_method, :sync_request, Proc.new{ |params, ids| { status: 200 } })
    set_fetch_request_response({ status: 200, for_sync: [], for_destroy: [] })
    @import = SyncableModels::Importer::Import.new :test
    @import.api_url = 'http://test.dev'
  end

  describe 'when importing permanent objects' do
    before do
      @project = create(:first_project, external_id: '8e9d12b3-5df0-46c3-ae19-6ac7d10879a4')
      @imported_uuid = SecureRandom.uuid
      @imported_name = 'ImportedProject'
      set_fetch_request_response({ status: 200,
        for_sync: [{ uuid: @imported_uuid, name: @imported_name }],
        for_destroy: ['8e9d12b3-5df0-46c3-ae19-6ac7d10879a4']
      })
      @import.import_model Project
      @import.import [Project]
    end

    describe 'subject for sync' do
      it 'imports correctly' do
        expect(Project.where(external_id: @imported_uuid).first).not_to be_nil
      end

      it 'has a correct name' do
        expect(Project.last.name).to eq(@imported_name)
      end

      it 'has a correct external_id' do
        expect(Project.last.external_id).to eq(@imported_uuid)
      end
    end

    describe 'subject for destroy' do
      it 'import correctly' do
        expect(Project.where(uuid: @project.uuid).first.deleted_at).not_to be_nil
      end
    end
  end

  describe 'when importing non-permanent objects' do
    before do
      @team = create(:first_team, external_id: 73)
      @imported_id = 42
      @imported_name = 'ImportedTeam'
      set_fetch_request_response({ status: 200,
        for_sync: [{ id: @imported_id, name: @imported_name }],
        for_destroy: ['73']
      })
      @import.import_model Team, api_id_key: :id
      @import.import [Team]
    end

    describe 'subject for sync' do
      it 'imports correctly' do
        expect(Team.where(external_id: @imported_id).first).not_to be_nil
      end

      it 'has a correct name' do
        expect(Team.last.name).to eq(@imported_name)
      end

      it 'has a correct external_id' do
        expect(Team.last.external_id).to eq(@imported_id.to_s)
      end
    end

    describe 'subject for destroy' do
      it 'import correctly' do
        expect(Team.find_by_id(@team.id)).to be_nil
      end
    end
  end
end
