class CreateSyncs < ActiveRecord::Migration
  def change
    create_table :syncs do |t|
      t.integer :subject_id
      t.string :subject_type
      t.string :destination

      t.timestamps
    end

    add_index :syncs, [:subject_id, :subject_type, :destination]
    add_index :syncs, :destination
  end
end
