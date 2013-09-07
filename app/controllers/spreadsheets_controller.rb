class SpreadsheetsController < ApplicationController
  before_filter :login_required
  before_action :find_user

  def new
    @spreadsheet = @user.spreadsheets.build
  end

  def show
    @spreadsheets = @user.spreadsheets
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
    @spreadsheet = @user.spreadsheets.find(params[:format])
  end

  def update
    @spreadsheet = @user.spreadsheets.find(params[:format])

    if @spreadsheet.update(spreadsheet_params)
      redirect_to user_spreadsheets_path(@user)
    else
      render :edit
    end
  end

  def destroy
    @spreadsheet = @user.spreadsheets.find(params[:format])

    @spreadsheet.destroy

    redirect_to user_spreadsheets_path(@user)
  end


  private

  def find_user
    @user = current_user
  end

  def spreadsheet_params
    params.require(:spreadsheet).permit(:content)
  end
end
