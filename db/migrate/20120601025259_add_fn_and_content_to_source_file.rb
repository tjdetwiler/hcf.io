class AddFnAndContentToSourceFile < ActiveRecord::Migration
  def change
    add_column :source_files, :code, :text
  end
end
