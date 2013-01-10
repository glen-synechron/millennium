class CreateSalons < ActiveRecord::Migration
  def change
    create_table :salons do |t|
      t.string :server
      t.string :user
      t.string :password
      t.string :guid
      t.string :session_id
      t.string :string
      t.time :start_time
      t.time :end_time

      t.timestamps
    end
  end
end
