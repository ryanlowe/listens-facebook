class ApplicationController < ActionController::Base
  session :disabled => true
  
  include ExceptionNotifiable
  include FacebookUtilities::ControllerUtilities
  
  protected
  
    def bounce
      render :partial => 'site/error_404'
    end
    
    def friend_of_user?(uid)
      return false if facebook.nil?
      return true if (facebook.user == uid.to_s)
      params[:fb_sig_friends].split(',').include?(uid.to_s)
    end
  
    def facebook_redirect_to(options = {}, *parameters_for_method_reference)
      options[:only_path] = true
      render :text => '<fb:redirect url="http://apps.facebook.com'+url_for(options)+'"/>'
    end
end
