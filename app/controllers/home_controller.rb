class HomeController < ApplicationController

  def overview

  end

  def about
    @about_page=true
  end

  def impressum
    @about_page=true
  end

  def help

  end

  def contact

  end

end
