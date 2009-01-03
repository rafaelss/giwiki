class UploadsController < ApplicationController

  def index
    @uploads = Upload.find :all, :conditions => ['title like ? or tags like ?', "%#{params[:search]}%", "%#{params[:search]}%"], :order => 'created_at DESC', :limit => 12
  end

  def new
    @upload = current_user.uploads.new
  end

  def create
    @upload = current_user.uploads.new(params[:upload])

    if @upload.save
      render :partial => "uploads/item", :locals => { :upload => @upload }
    else
      render :partial => "new"
    end
  end
end
