class CreateCommandRepeaters < ActiveRecord::Migration[5.0]
  def change
    create_table :command_repeaters do |t|
      t.date    :start_at
      t.integer :cycle_seconds
      t.integer :status_id
      t.integer :channel_id
      t.integer :command_type_id
      t.string  :command_name
      t.integer :command_id

      t.timestamps
    end
  end
end
