class CreateChannelModerators < ActiveRecord::Migration[5.0]
  def up
    create_table :channel_moderators do |t|
      t.string :moderator_name
      t.string :channel_bot_id

      t.timestamps
    end
  end

  def down
    drop_table :channel_moderators
  end
end
