class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name, null: false
      t.string :uuid, null: false
      t.datetime :deleted_at, null: true
      t.string :external_id
      t.timestamps null: false
    end

    add_index :projects, :uuid, unique: true, length: 36
  end
end
