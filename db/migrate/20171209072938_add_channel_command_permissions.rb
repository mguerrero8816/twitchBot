class AddChannelCommandPermissions < ActiveRecord::Migration[5.0]
  def up
    create_table :channel_command_permissions do |t|
      t.integer :permission_id
      t.integer :custom_command_id
      t.string  :twitch_command_name
      t.integer :channel_bot_id

      t.timestamps
    end
  end

  def down
    drop_table :channel_command_permissions
  end
end
