#--
# Copyright (c) 2007 Chris Taggart
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++
module FacebookUtilities
#FACEBOOK_API_KEY     = "09ed660b6377207107f4ddd118974166"
#FACEBOOK_API_SECRET  = "d265fa3586914d7d4a63c53e1362a967"
FACEBOOK_API_URL     = "api.facebook.com"
FACEBOOK_API_PATH    = "/restserver.php"
FACEBOOK_API_VERSION = "1.0"

# The Facebook class handles the meat of the interaction with Facebook.
# 
# Unless it makes sense not to I've tended to stay close to the PHP library's functionality, although obviously not the code structure.
# Where I haven't it's because: it didn't make sense; I didn't need that bit of funcionlity yet; I forgot; or some other arbitrary explanation
# 
# Facebook methods are called by making them a bit ruby-ish, and preceding them with "fb_". So to call users.isAppAdded
# we use the method #fb_users_is_app_added (we use the fb_ prefix in order to use method_missing responsibly, which in turn saves masses of code).
# NB In the case where the facebook method has a word in all caps, e.g. profile.setFBML, you can either call it with fb_profile_set_fBML, or the 
# slightly less unattractive fb_profile_set_FBML
# 
# If a call to the Facebook API returns an error response from Facebook (see http://wiki.developers.facebook.com/index.php/Error_codes) a
# FacebookUtilities::Facebook::FacebookApiError exception is raised and the error logged using the Rails default logger. How your app handles 
# it is up to you :-)

  class Facebook
    attr_reader   :session_key, :user, :fb_params
    
    # Define custom error class for Facebook API errors
    class FacebookApiError < StandardError  
    end
    
    # We initialize with given params hash, extracting the fb_params from it and using them to set session key and facebook user
    def initialize(params={})
      @fb_params   = get_fb_params(params)
      @session_key = @fb_params[:session_key]
      @user        = @fb_params[:user]
      get_new_session(params[:auth_token]) if params[:auth_token]&&!@session_key
    end
    
    # Returns whether user has added this application
    def added_app?
      @fb_params[:added] == "1"
    end
    
    # Returns the url to add the application to the user's list of apps
    def add_app_url(options={})
      "http://www.facebook.com/add.php?api_key=#{FACEBOOK_API_KEY}" + (options[:next] ? "&next=#{CGI.escape(options[:next])}" : "")
    end
    
    # Returns the login url for this application. Various params can be passed through the options hash. If these have a 
    # string as a value then that string is URL-escaped, if it is false the param is ingored, otherwise it's just added as 
    # a key=value pair
    def login_to_app_url(options={})
      base_url = "http://www.facebook.com/login.php?v=#{FACEBOOK_API_VERSION}&api_key=#{FACEBOOK_API_KEY}"
      options.each { |k,v| (base_url += "&#{k}=#{v.is_a?(String) ? CGI.escape(v) : v}") if v } 
      base_url
    end
    
    # Converts the rubyish method into Facebook method, makes the request and processes the XML returned
    def call(method, params={})
      split_method = method.to_s.split("_",2)
      fb_method = "facebook.#{split_method.first}.#{split_method[1].camelize(:lower)}"
      response = post_request(fb_method, params)
      RAILS_DEFAULT_LOGGER.debug "****Facebook method #{fb_method} called with #{params.inspect}. \n Response: #{response.inspect}" # Helpful when trying to track down problems
      xml = XmlSimple.xml_in(response)
      RAILS_DEFAULT_LOGGER.debug "***Facebook API error: #{xml.inspect}" and raise FacebookApiError if xml["error_code"]
      xml
    end
    
    # Returns only the facebook parameters from the parameters hash (these are the ones starting with 'fb_sig_'). Also renames the keys to these parameters by removing the 'fb_sig_'.
    # Checks we have valid facebook params by verifying the signature and also checking the params are not stale (>48 hours old). Returns an empty hash if no fb_parameters or if
    # signature is invalid or if params are stale
    def get_fb_params(orig_params={})
      new_params = {}
      orig_params.each { |k,v| m = /^fb_sig_(.+)/.match(k.to_s); new_params.update({m[1].to_sym => v}) if m&&m[1]}
      new_params[:time]&&(Time.at(new_params[:time].to_f) >= 48.hours.ago)&&verify_signature(new_params, orig_params[:fb_sig]) ? new_params : {}
    end
    
    # Gets a new session given an auth code
    def get_new_session(auth_token)
      response = fb_auth_get_session(:auth_token => auth_token)
      @session_key = response["session_key"].first
      @user = response["uid"].first
    end
    
    # Returns true if we're in a facebook canvas
    def in_canvas?
      @fb_params[:in_canvas]
    end
    
    # Returns true if we're in a facebook iframe
    def in_iframe?
      @fb_params[:in_iframe]
    end
    
    # Returns true if we're in any sort of facebook frame -- canvas or iframe
    def in_frame?
      in_canvas? || in_iframe?
    end
    
    # Checks whether user is logged into app. If they are there will be a session and a user. Returns user id if true, false otherwise
    def logged_in_to_app?
      @session_key&&@user
    end
    
    # Build the required parameters for a Facebook API call, including the signature, and calls post_http_request to submit request to Facebook
    def post_request(method, params)
      post_params = { "api_key" => FACEBOOK_API_KEY, 
                      "call_id" => Time.now.to_f.to_s, 
                      "method" => method, 
                      "v" => FACEBOOK_API_VERSION,
                      "session_key" => session_key }.merge(params.stringify_keys) # Net::HTTP (and Facebook prob) expects keys to be strings
      post_http_request(FACEBOOK_API_URL, FACEBOOK_API_PATH, post_params.merge({ "sig" => signature_from(post_params) } ))
    end
    
    # Generates a facebook signature from the params hash passed
    def signature_from(params={})
      request_str = params.collect {|p| "#{p[0].to_s}=#{p[1]}"}.sort.join # build key value pairs, sort in alpha order then join them
      return Digest::MD5.hexdigest("#{request_str}#{FACEBOOK_API_SECRET}")
    end
    
    # Verifies that the signature given matches the signature that would be generated for the passed parameters
    def verify_signature(params, given_signature)
      given_signature == signature_from(params)
    end
    
    protected
    # Separating this out makes mocking easier
    def post_http_request(url, path, params)
      return false if RAILS_ENV=="test" #make sure we don't call make calls to external services. Mock this method to simulate response instead
      http_server = Net::HTTP.new(url, 80)
      http_request = Net::HTTP::Post.new(path)
      http_request.form_data = params
      RAILS_DEFAULT_LOGGER.debug "****facebook API call: #{params.inspect}"
      http_server.start{|http| http.request(http_request)}.body      
    end
    
    private
    # All API methods are implemented with this method. It extracts the remote method API name
    # based on the ruby method name. That method should be preceded with fb_ (we don't want just
    # any unknown method scooped up -- makes bug-tracking v difficult). So we call the Facebook method
    # users.isAppAdded by the more rubyish fb_users_is_app_added 
    def method_missing(unknown_method_name, *args)
      if match = /fb_(.+)/.match(unknown_method_name.to_s)
        call(match[1], *args)
      else 
        super
      end
    end    
  end

  # #
  # This module adds extra functionality to Rails controllers. In particular it adds an interface to the 
  # Facebook object, and adds some private methods which make it all a bit easier. Simply "include FacebookUtilities::ControllerUtilities" 
  # in the controllers you want to eb facebook aware (or in the application controller if you want all of them to have access to these methods)
  # #
  module ControllerUtilities
    private
    
    # provides interface to facebook object, instantiating with the params hash if it does not yet exist
    def facebook
      @facebook ||= FacebookUtilities::Facebook.new(params)
    end
    
    # Provides redirection to given facebook page (e.g. to login to app or to facebook itself).
    # If we are in an fb_canvas page we perform redirection by returning text in the form of '<fb:redirect url=http://some.url.com/>' 
    def fb_redirect_to(url)
      if facebook.in_canvas?
        render :text => "<fb:redirect url=\"#{url}\" />" 
      elsif url=~/^https?:\/\/([^\/]*\.)?facebook\.com(:\d+)?/i
        render :text => "<script type=\"text/javascript\">\ntop.location.href = \"#{url}\";\n</script>"
      else
        redirect_to url
      end
    end
    
    # Call this method with a before_filter for actions that need facebook user to have added your application
    def require_added_fb_app
      return true if facebook.added_app?
      fb_redirect_to facebook.add_app_url
      return false
    end
    
    # Call this method with a before_filter for actions that need facebook user to be logged into your application (i.e. where you need a facebook session and/or their user id)
    def require_logged_in_to_fb_app
      return true if facebook.logged_in_to_app?
      fb_redirect_to facebook.login_to_app_url(:canvas => facebook.in_frame?)
      return false
    end
    
    # Call this method with a before_filter for actions that need can only be accessed from within a facebook frame
    def require_fb_frame
      return true if facebook.in_frame?
      redirect_to facebook.login_to_app_url
      return false
    end    
  end  
end