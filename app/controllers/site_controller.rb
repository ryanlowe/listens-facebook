class SiteController < ApplicationController
  layout "dashboard"
  helper :album
  helper :listen
  helper :public

  def faq
    @uid = facebook.user
    @faq_selected = "selected='true'"
  end
  
  def blow
    raise "Woah!"
  end
end
