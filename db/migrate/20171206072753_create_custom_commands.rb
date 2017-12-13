class CreateCustomCommands < ActiveRecord::Migration[5.0]
  def up
    create_table :custom_commands do |t|
      t.string  :command
      t.string  :response
      t.integer :channel_id

      t.timestamps
    end
  end

  def down
    drop_table :custom_commands
  end
end
