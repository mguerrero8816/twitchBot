class CreateSchedules < ActiveRecord::Migration[5.0]
  def up
    create_table :schedules do |t|
      t.string   :title
      t.string   :description
      t.integer  :game_id
      t.datetime :start_at
      t.integer  :channel_id

      t.timestamps
    end
  end

  def down
    drop_table :schedules
  end
end
