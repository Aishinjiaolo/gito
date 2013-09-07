class SpreadsheetsController < ApplicationController
  before_filter :login_required
  before_action :find_user

  def index
    @spreadsheets = @user.spreadsheets.all
  end

  def new
    @spreadsheet = @user.spreadsheets.build
  end

  def show
    @spreadsheet = @user.spreadsheets.find(params[:id])
  end

  def create
    @spreadsheet = @user.spreadsheets.new(spreadsheet_params)

    if @spreadsheet.save
      redirect_to user_spreadsheets_path(@user)
    else
      render :new
    end
  end

  def edit
    @spreadsheet = @user.spreadsheets.find(params[:id])
  end

  def update
    @spreadsheet = @user.spreadsheets.find(params[:id])

    if @spreadsheet.update(spreadsheet_params)
      redirect_to user_spreadsheet_path
    else
      render :edit
    end
  end

  def destroy
    @spreadsheet = @user.spreadsheets.find(params[:id])

    @spreadsheet.destroy

    redirect_to user_spreadsheets_path
  end


  private

  def find_user
    @user = current_user
  end

  def find_spreadsheet
    @user.spreadsheets.find(params[:id])
  end

  def spreadsheet_params
    params.require(:spreadsheet).permit(:content)
  end
end
