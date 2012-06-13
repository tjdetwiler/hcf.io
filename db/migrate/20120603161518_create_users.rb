class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :pw_hash
      t.string :pw_salt

      t.timestamps
    end
  end
end
