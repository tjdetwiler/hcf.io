class SourceFilesController < ApplicationController

  # GET /projects/:id/source_files/:file_name
  # GET /projects/:id/source_files/:file_name.json
  def index
    
  end

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

  def show
    @project = Project.find params[:project_id]
    @file = @project.source_files.find_by_name params[:id]
  
    respond_to do |format|
      format.html 
      format.json {render json: @file}
    end
  end

  def update
    @user = session[:user]
    @project = Project.find params[:project_id]
    @file = @project.source_files.find_by_name params[:id]

    @file.code = params[:code]
    respond_to do |format|
      if @file.save
        p "\nok\n"
        format.html { redirect_to @file }
        format.json { head :ok }
      else
        p "\nerror\n"
        format.html { render action: "edit" }
        format.json { render json: @file.errors, status: :unprocessable_entity }
      end
    end
  end
end
