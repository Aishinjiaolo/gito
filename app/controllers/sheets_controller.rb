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
      puts file
      FileUtils.mkdir_p(path)
      File.open(file, 'w') do |f|
        f.write(JSON.pretty_generate(sheetdata.as_json))
      end
    else
      redirect_to user_sheet_path
    end
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
