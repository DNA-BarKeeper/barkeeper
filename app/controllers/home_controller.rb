class HomeController < ApplicationController

  def overview
    authorize! :overview, :home
  end

  def about
    @about_page = true
    authorize! :about, :home
  end

  def impressum
    @about_page = true
    authorize! :impressum, :home
  end

  def help

  end

  def contact

  end

end
