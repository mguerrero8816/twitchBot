class CreateTwitchBot < ActiveRecord::Migration[5.0]
  def change
    create_table :twitch_bots do |t|
      t.integer :live_status_id
      t.integer :intended_status_id
      t.string  :channel_name
      t.string  :bot_name

      t.timestamps
    end
  end
end
