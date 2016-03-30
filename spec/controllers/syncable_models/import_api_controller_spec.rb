require 'rails_helper'

RSpec.describe ImportApiController, type: :controller do
  let(:json) { JSON.parse(response.body) }
  let(:for_sync) { json['for_sync'] }
  let(:for_destroy) { json['for_destroy'] }

  describe '#fetch method' do
    before do
      @teams = [create(:first_team),
        create(:second_team),
        create(:third_team),
        create(:fourth_team)]
    end

    it 'fetches objects if all unsynced' do
      get :teams, destination: :test
      expect(for_sync.count).to eq(4)
    end

    it 'fetches only unisynced objects' do
      @teams.last.sync(:test)
      get :teams, destination: :test
      expect(for_sync.count).to eq(3)
    end

    describe 'fetching mixed response' do
      before do
        @teams.last(2).each{ |t| t.sync(:test) }
        @teams.last(2).each(&:destroy)
      end

      it 'fetches destroyed syncs' do
        get :teams, destination: :test
        expect(for_destroy.count).to eq(2)
      end

      it 'response still has undestroyed syncs' do
        get :teams, destination: :test
        expect(for_sync.count).to eq(2)
      end

      describe 'when using limit' do
        it 'returns correct amount of for_sync objects' do
          get :teams, destination: :test, count: 3
          expect(for_sync.count).to eq(2)
        end

        it 'returns correct amount of for_destroy objects' do
          get :teams, destination: :test, count: 3
          expect(for_destroy.count).to eq(1)
        end
      end
    end
  end

  describe '#sync method' do
    it 'syncs objects' do
      teams = [create(:first_team), create(:second_team), create(:third_team)]
      get :sync_teams, destination: :test, ids: teams.first(2).map(&:id)
      expect(Team.synced(:test)).to eq(teams.first(2))
    end

    describe 'when objects destroyed' do
      describe 'and they are non-permanent' do
        before do
          @teams = [create(:first_team), create(:second_team), create(:third_team)]
          @teams.each{ |o| o.sync(:test) }
          @teams.first(2).each(&:destroy)
          get :sync_teams, destination: :test, ids: @teams.first(2).map(&:id)
        end

        it 'destroys their syncs' do
          expect(SyncableModels::Sync.count).to eq(1)
        end

        it 'keeps the remaining syncs' do
          expect(SyncableModels::Sync.first.subject).to eq(@teams.last)
        end
      end

      describe 'and they are permanent' do
        before do
          @projects = [create(:first_project), create(:second_project), create(:third_project)]
          @projects.each{ |o| o.sync(:test) }
          @projects.first(2).each(&:destroy)
          get :sync_projects, destination: :test, ids: @projects.first(2).map(&:uuid)
          @projects.each(&:reload)
        end

        it 'destroys their syncs' do
          expect(SyncableModels::Sync.count).to eq(1)
        end

        it 'doesn\'t put destroyed objects to the list sync' do
          get :projects, destination: :test
          expect(for_sync.count).to eq(0)
        end

        it 'put destroyed objects to the sync list after revive' do
          @projects.first(2).each(&:revive)
          get :projects, destination: :test
          expect(for_sync.count).to eq(2)
        end
      end
    end
  end
end
