require 'rails_helper'

RSpec.describe SyncableModels::Sync, type: :model do
  it 'it syncs subject succesfully' do
    project = create(:first_project)
    project.sync(:test)
    expect(project.syncs.count).to eq(1)
  end

  describe '#subject_external_id initializing' do
    it 'initializes with uuid' do
      project = create(:first_project)
      project.sync(:test)
      expect(project.syncs.first.subject_external_id).to eq(project.uuid.to_s)
    end

    it 'initializes with id' do
      team = create(:first_team)
      team.sync(:test)
      expect(team.syncs.first.subject_external_id).to eq(team.id.to_s)
    end
  end

  describe '#subject' do
    it 'points to it\'s subject' do
      project = create(:first_project)
      project.sync(:test)
      sync = project.syncs.first
      expect(sync.subject).to eq(project)
    end

    it 'points to it\'s subject by subject_external_id when uuid' do
      project = create(:first_project)
      project.sync(:test)
      sync = project.syncs.first
      sync.update_attribute :subject_id, nil
      expect(sync.subject).to eq(project)
    end

    it 'points to it\'s subject by subject_external_id when id' do
      team = create(:first_team)
      team.sync(:test)
      sync = team.syncs.first
      sync.update_attribute :subject_id, nil
      expect(sync.subject).to eq(team)
    end

    it 'points to it\'s subject when direct association destroyed' do
      project = create(:first_project)
      project.sync(:test)
      sync = project.syncs.first
      project.destroy
      sync.reload
      expect(sync.subject).to eq(project)
    end
  end

  describe 'subject destroying' do
    before do
      @team = create(:first_team)
      @team.sync(:test)
      @id = @team.id
      @sync = @team.syncs.first
      @team.destroy
      @sync.reload
    end

    it 'not destroys sync' do
      expect(@sync).to_not be_nil
    end

    it 'clears sync subject_id' do
      expect(@sync.subject_id).to be_nil
    end

    it 'cannot point to the subject' do
      expect(@sync.subject).to be_nil
    end

    it '#subject_destroyed has false value' do
      expect(@sync.subject_destroyed).to be_truthy
    end

    it 'stores subject\'s id' do
      expect(@sync.subject_external_id).to eq(@id.to_s)
    end
  end
end
