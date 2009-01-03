class PagesController < ApplicationController
  before_filter :load_last_uploads, :only => [:new, :edit]

  def index
    @pages = Page.all

    respond_to do |format|
      format.html
      format.rss
    end
  end

  def new
    @page = Page.new(params[:page_id])
    render(:action => 'edit')
  end

  def show
    unless params[:commit_id].nil?
      @page = Page.find_by_commit_id(params[:commit_id])

      redirect_to page_url(params[:page_id]) if @page.nil?
    else
      @page = Page.find_by_title(params[:id])

      redirect_to page_new_url(params[:id]) if @page.nil?
    end
  end

  def edit
    @page = Page.find_by_title(params[:id])

    unless logged_in?
      redirect_to page_url(@page)
    end
  end

  def update
    @page = Page.find_by_title(params[:page][:title])
    if @page.nil?
      @page = Page.new(params[:id])
    end

    @page.author = current_user
    @page.body = params[:page][:body]
    if @page.save(params[:page][:message])
      redirect_to page_url(@page)
    else
      redirect_to edit_page_url(@page)
    end
  end

  def history
    @page = Page.find_by_title(params[:page_id])
  end

  private
    def load_last_uploads
      @upload = Upload.new
      @uploads = Upload.find :all, :order => 'created_at DESC', :limit => 12
    end
end
