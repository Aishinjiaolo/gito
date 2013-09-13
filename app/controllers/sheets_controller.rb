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

    @sheet.destroy

    redirect_to user_sheets_path
  end

  def upload
    @sheet = find_sheet
    @uploader = @sheet.sheetdata
    @uploader.success_action_redirect = edit_user_sheet_url
  end


  private

  def find_user
    @user = current_user
  end

  def find_sheet
    @user.sheets.find(params[:id])
  end

  def sheet_params
    params.require(:sheet).permit(:path, :sheetdata)
  end
end
