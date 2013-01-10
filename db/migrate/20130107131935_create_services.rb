class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.integer :service_id
      t.string :service_class
      t.string :service_sub_class
      t.float :price

      t.timestamps
    end
  end
end
