class CreateChannelBots < ActiveRecord::Migration[5.0]
  def up
    create_table :channel_bots do |t|
      t.integer :live_status_id
      t.integer :intended_status_id
      t.string  :bot_name
      t.integer :channel_id

      t.timestamps
    end
  end

  def down
    drop_table :channel_bots
  end
end
