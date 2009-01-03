class SearchController < ApplicationController

  def index
    @pages = Page.search(params[:s])
  end
end
