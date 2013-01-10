class AddFieldsToServices < ActiveRecord::Migration
  def change
    add_column :services, :start_length, :string
    add_column :services, :gap_length, :string
    add_column :services, :finish_length, :string
  end
end
