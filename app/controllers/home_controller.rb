# frozen_string_literal: true

class HomeController < ApplicationController
  def progress
    authorize! :progress, :home
  end

  def about
    @about_page = true
    authorize! :about, :home
  end

  def impressum
    @about_page = true
    authorize! :impressum, :home
  end

  def privacy_policy
    @about_page = true
    authorize! :privacy_policy, :home
  end

  def help; end

  def contact; end
end
