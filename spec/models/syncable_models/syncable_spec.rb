require 'rails_helper'

RSpec.describe SyncableModels::Syncable do
  before do
    @first_project = create(:first_project)
    @second_project = create(:second_project)
    @third_project = create(:third_project, name: 'TestProject')
  end

  describe '#syncable_models_suitable' do
    it 'returns all projects when no condition to destination' do
      projects = Project.syncable_models_suitable(:test)
      expect(projects).to include(@first_project, @second_project, @third_project)
    end

    describe 'when there is condition for destination' do
      before { @projects = Project.syncable_models_suitable(:condition_test) }

      it 'returns not all objects' do
        expect(@projects).to_not include(@third_project)
      end

      it 'returns relation' do
        expect(@projects).to be_a(ActiveRecord::Relation)
      end
    end
  end
end
