class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name, null:false
      t.string :external_id
      t.timestamps null: false
    end
  end
end
