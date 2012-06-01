class AddNameToSourceFiles < ActiveRecord::Migration
  def change
    add_column :source_files, :name, :string
  end
end
