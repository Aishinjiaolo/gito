class SheetsController < ApplicationController
  before_filter :login_required
  before_action :find_user

  S3_BUCKET = 'gito_user_repo'
  DATA_FILE = 'data.json'

  def index
    @sheets = @user.sheets.all
  end

  def new
    @sheet = @user.sheets.build
  end

  def show
    @sheet = find_sheet
    @load_url = "#{@sheet.id}/load_data"
    @save_url = "#{@sheet.id}/save_data"
    load_local_data
  end

  def create
    @sheet = @user.sheets.new(sheet_name)

    if @sheet.save
      redirect_to user_sheets_path
      create_local_repo
    else
      render :new
    end
  end

  def edit
    @sheet = find_sheet
  end

  def update
    @sheet = find_sheet

    if @sheet.update(sheet_name)
      redirect_to user_sheet_path
    else
      render :edit
    end
  end

  def destroy
    @sheet = find_sheet
    destory_local_tmp_file
    destroy_s3_object
    @sheet.destroy
    redirect_to user_sheets_path
  end

  def upload
    @sheet = find_sheet
    push(find_local_path)
    redirect_to user_sheet_path
  end

  def pull
    @sheet = find_sheet
    update_local_repo
    redirect_to user_sheet_path
  end

  #TODO: for user load image maybe
  def upload_backup
    @sheet = find_sheet
    @uploader = @sheet.sheetdata
    @uploader.success_action_redirect = upload_user_sheet_url
    if params[:key]
      @sheet.update(:path => params[:key])
      redirect_to user_sheet_path
    end
  end

  def load_data
    @sheet = find_sheet
    load_local_data
    data = {"data" => @sheetdata}
    respond_to do |format|
      format.json  { render :json => data }
    end
  end

  def save_data
    if params[:data]
      sheetdata = params[:data]
      respond_to do |format|
        format.json  {
          render :json => {
            result: 'ok',
            location: url_for(:controller => 'sheets', :action => 'show')
          }
        }
      end

      @sheet = find_sheet
      path = find_local_path
      file = "#{path}/#{DATA_FILE}"

      clone_s3 unless File.exist?(file)

      File.open(file, 'w') do |f|
        f.write(JSON.pretty_generate(sheetdata.as_json))
      end

      git = Git::init(path)
      git.add

      begin
        message = 'message: ' + Time.now.to_s
        #TODO: ohmygod should be user name
        git.commit_all(message, :author => "ohmygod <#{@user.email}>")
      rescue
        Rails.logger.info 'nothing to commit'
      end
    else
      redirect_to user_sheet_path
    end
  end

  def history
    @sheet = find_sheet
    git = Git::init(find_local_path)

    #TODO: this is ugly
    @commits = []
    commits_by_day = []
    this_date = nil
    git.log.since('one week ago').each do |c|
      date = c.date.strftime("%m-%d-%y")
      if this_date == date || this_date == nil
        commits_by_day << c
        this_date = date
      else
        @commits << commits_by_day
        commits_by_day = []
        this_date = date
      end
    end
    @commits << commits_by_day
  end


  private

  def find_user
    @user = current_user
  end

  def find_sheet
    @user.sheets.find(params[:id])
  end

  def find_local_path
    path = "#{Rails.root}/tmp/s3/#{@user.id}/#{@sheet.id}"
  end

  def find_data_template_file
    file = "#{Rails.root}/app/assets/data_template/#{DATA_FILE}"
  end

  def find_upload_folder
    folder = "uploads/#{@sheet.id}.git"
  end

  def find_s3_url
    s3_url = "amazon-s3://.jgit@#{S3_BUCKET}/#{find_upload_folder}"
  end

  def sheet_name
    params.require(:sheet).permit(:name)
  end

  def destroy_s3_object
    s3     = AWS::S3.new
    bucket = s3.buckets[S3_BUCKET]
    bucket.objects.with_prefix(find_upload_folder).delete_all
  end

  def destory_local_tmp_file
    FileUtils.remove_entry(find_local_path, :force => true)
  end

  def push(local_repo_path)
    push = "#{Rails.root}/bin/jgit --git-dir=#{local_repo_path}/.git push"
    IO.popen(push) { |result| Rails.logger.info result.gets }
  end

  def create_local_repo
    path = find_local_path
    file = "#{path}/#{DATA_FILE}"
    FileUtils.mkdir_p(path)
    FileUtils.copy(find_data_template_file, file)
    git = Git::init(path)
    git.add
    message = 'message: ' + Time.now.to_s
    git.commit_all(message)
    remote = git.add_remote("origin", find_s3_url)
    push(path)
  end

  def update_local_repo
    path = find_local_path
    fetch = "#{Rails.root}/bin/jgit --git-dir=#{path}/.git fetch"
    IO.popen(fetch) { |result| Rails.logger.info result.gets }
    # TODO: do merge if any result then
    git = Git::init(path)
    git.merge('origin/master')
  end

  def clone_s3
    clone = "#{Rails.root}/bin/jgit clone #{find_s3_url} #{find_local_path}"
    IO.popen(clone) { |result| Rails.logger.info result.gets }
  end

  def sheet_data_convert(json_hash)
    data = []
    json_hash.each do |key, value|
      data[key.to_i] = value
    end
    return data
  end

  def load_local_data
    file = "#{find_local_path}/#{DATA_FILE}"
    clone_s3 unless File.exist?(file)
    @sheetdata = sheet_data_convert(
      JSON.parse(
        File.read(file)
      )
    )
  end
end
