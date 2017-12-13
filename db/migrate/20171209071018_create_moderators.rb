class CreateModerators < ActiveRecord::Migration[5.0]
  def up
    create_table :moderators do |t|
      t.string :moderator_name
      t.string :channel_id

      t.timestamps
    end
  end

  def down
    drop_table :moderators
  end
end
