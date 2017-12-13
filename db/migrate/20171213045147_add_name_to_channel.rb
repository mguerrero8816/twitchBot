class AddNameToChannel < ActiveRecord::Migration[5.0]
  def up
    add_column :channels, :name, :string
  end

  def down
    remove_column :channels, :name
  end
end
