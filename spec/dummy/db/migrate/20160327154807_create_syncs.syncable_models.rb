# This migration comes from syncable_models (originally 20160225141153)
class CreateSyncs < ActiveRecord::Migration
  def change
    create_table :syncs do |t|
      t.integer :subject_id
      t.string :subject_type
      t.string :destination, null: false

      t.string :subject_external_id, null: false
      t.boolean :subject_destroyed, null: false, default: false

      t.timestamps
    end

    add_index :syncs, [:subject_id, :subject_type, :destination]
    add_index :syncs, :destination
    add_index :syncs, [:subject_external_id, :subject_destroyed]
  end
end
