class CreateSourceFiles < ActiveRecord::Migration
  def change
    create_table :source_files do |t|

      t.timestamps
    end
  end
end
