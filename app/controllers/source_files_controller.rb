class SourceFilesController < ApplicationController

  # POST /projects/1/files
  # POST /projects/1/files.json
  def create
    @project = Project.find params[:project_id]
    @file = @project.source_files.create :name=>params[:name], :code=>params[:code]

    respond_to do |format|
      if @file.save 
        format.html {redirect_to @project}
        format.json {render json: @file}
      end
    end
  end
end
