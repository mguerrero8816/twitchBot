class CreateChannelBots < ActiveRecord::Migration[5.0]
  def up
    create_table :channel_bots do |t|
      t.integer :live_status_id
      t.integer :intended_status_id
      t.string  :channel_name
      t.string  :bot_name

      t.timestamps
    end
  end

  def down
    drop_table :channel_bots
  end
end
