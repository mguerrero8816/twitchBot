class CreateCommandPermissions < ActiveRecord::Migration[5.0]
  def up
    create_table :command_permissions do |t|
      t.integer :permission_id
      t.integer :channel_id
      t.integer :command_type_id
      t.string  :command_name
      t.integer :command_id

      t.timestamps
    end
  end

  def down
    drop_table :command_permissions
  end
end
