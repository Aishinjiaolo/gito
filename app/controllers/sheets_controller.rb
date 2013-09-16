class SheetsController < ApplicationController
  before_filter :login_required
  before_action :find_user

  def index
    @sheets = @user.sheets.all
  end

  def new
    @sheet = @user.sheets.build
  end

  def show
    @sheet = find_sheet
    @load_url = "#{@sheet.id}/load"
    @save_url = "#{@sheet.id}/save"
    @sheetdata =
      [
        ["", "Kia", "Nissan", "Toyota", "Honda"],
        ["2008", 10, 11, 12, 13],
        ["2009", 20, 11, 14, 13],
        ["2010", 30, 15, 12, 13],
        ["2010", 30, 15, 12, 13],
        ["2010", 30, 15, 12, 13],
        ["2010", 30, 15, 12, 13],
        ["2010", 30, 15, 12, 13],
      ]
  end

  def create
    @sheet = @user.sheets.new(sheet_params)

    if @sheet.save
      redirect_to user_sheets_path
    else
      render :new
    end
  end

  def edit
    @sheet = find_sheet
  end

  def update
    @sheet = find_sheet

    if @sheet.update(sheet_params)
      redirect_to user_sheet_path
    else
      render :edit
    end
  end

  def destroy
    @sheet = find_sheet

    destroy_s3_file(@sheet.sheetdata)
    @sheet.destroy

    redirect_to user_sheets_path
  end

  def upload
    @sheet = find_sheet
    @uploader = @sheet.sheetdata
    @uploader.success_action_redirect = upload_user_sheet_url
    if params[:key]
      @sheet.update(:path => params[:key])
      redirect_to user_sheet_path
    end
  end

  def load
    @sheetdata =
      [
        ["", "Kia", "Nissan", "Toyota", "Honda"],
        ["20080", 10, 11, 12, 13],
        ["20090", 20, 11, 14, 13],
        ["20100", 30, 15, 12, 13],
        ["20100", 30, 15, 12, 13],
        ["20100", 30, 15, 12, 13],
        ["20100", 30, 15, 12, 13],
        ["20100", 30, 15, 12, 13],
      ]
    data = {"data" => @sheetdata}
    respond_to do |format|
      format.json  { render :json => data }
    end
  end

  def save
    if params[:data]
      sheetdata = params[:data]
      respond_to do |format|
        format.html  { redirect_to user_sheet_path }
        format.json  { render :json => { result: 'ok' } }
      end

      @sheet = find_sheet
      path = "#{Rails.root}/tmp/#{@sheet.path}"
      file = "#{path}/data.json"
      FileUtils.mkdir_p(path)

      File.open(file, 'w') do |f|
        f.write(JSON.pretty_generate(sheetdata.as_json))
      end

      git = Git::init(path)
      git.add

      begin
        message = 'message: ' + Time.now.to_s
        git.commit_all(message)
      rescue
        puts 'nothing to commit'
      end
    else
      redirect_to user_sheet_path
    end
  end

  def upload_s3
    clone = "#{Rails.root}/bin/jgit clone amazon-s3://.jgit@gito_user_repo/jgit_test.git tmp/uploads/jgit_test"
    IO.popen(clone) { |result| puts result.gets }
    g = Git.open("tmp/uploads/jgit_test", :log => Logger.new(STDOUT))
    commits = g.log
    commits.each { |commit| puts commit.message }
    redirect_to user_sheet_path
  end

  def upload_s3_backup
    require 'find'
    @sheet = find_sheet
    s3     = AWS::S3.new
    bucket = s3.buckets['gito_user_repo']
    pre    = "#{Rails.root}/tmp/"
    path   = "#{pre}#{@sheet.path}"

    Find.find(path) do |this_path|
      next if FileTest.directory?(this_path)
      key = this_path.sub(pre, '')
      object = bucket.objects[key].write(Pathname.new(this_path))
    end
    redirect_to user_sheet_path
  end


  private

  def find_user
    @user = current_user
  end

  def find_sheet
    @user.sheets.find(params[:id])
  end

  def sheet_params
    params.require(:sheet).permit(:path)
  end

  def destroy_s3_file(uploader)
    s3     = AWS::S3.new
    bucket = s3.buckets[uploader.fog_directory]
    object = bucket.objects[@sheet.path]
    object.delete
  end
end
