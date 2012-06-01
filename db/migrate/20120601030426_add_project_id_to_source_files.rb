class AddProjectIdToSourceFiles < ActiveRecord::Migration
  def change
    add_column :source_files, :project_id, :integer
  end
end
