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

require File.dirname(__FILE__) + '/../test_helper'

# Tests FacebookUtilities::Facebook class. NB uses Mocha
class FacebookTest < Test::Unit::TestCase
  
  def test_should_instantiate_new_facebook_object
    assert FacebookUtilities::Facebook.new
  end
  
  def test_should_have_session_key_and_user_and_fb_params_as_getters
    assert fb_object.respond_to?(:session_key)
    assert fb_object.respond_to?(:user)
    assert fb_object.respond_to?(:fb_params)
    %w(@session_key @user @fb_params).each do |a|
      assert fb_object.instance_variables.include?(a)      
    end    
  end
  
  def test_should_have_fb_params_as_getter
    assert fb_object.respond_to?(:fb_params)
    assert fb_object.instance_variables.include?("@fb_params")
  end
  
  def test_should_instantiate_with_raw_params_and_give_access_to_session_key_and_user
    stub_signature_verication # fake verifying of signature -- we test that separately
    fb = fb_object(dummy_fb_params(:fb_sig_session_key => "1234foo", :fb_sig_user => "987bar"))
    assert_equal "1234foo", fb.session_key
    assert_equal "987bar", fb.user
  end
  
  def test_should_get_new_session_if_auth_key_in_params_when_instantiating
    stub_signature_verication # fake verifying of signature -- we test that separately
    FacebookUtilities::Facebook.any_instance.expects(:get_new_session).with("foo123")
    fb_object(dummy_fb_params(:auth_token => "foo123"))
  end
  
  def test_should_not_get_new_session_if_already_have_session_when_instantiating
    stub_signature_verication # fake verifying of signature -- we test that separately
    FacebookUtilities::Facebook.any_instance.expects(:get_new_session).never
    fb_object(dummy_fb_params(:fb_sig_session_key => "1234foo", :auth_token => "foo123"))
  end
  
  def test_should_return_signature_from_given_params
    assert fb_object.respond_to?(:signature_from)
    assert_equal Digest::MD5.hexdigest(FACEBOOK_API_SECRET), fb_object.signature_from
    assert_equal Digest::MD5.hexdigest("a_param=1234xb_param=5678yc_param=97531t#{FACEBOOK_API_SECRET}"), fb_object.signature_from({:b_param => "5678y", :c_param => "97531t", :a_param => "1234x"})
  end
  
  def test_should_verify_signature
    assert fb_object.respond_to?(:verify_signature)
    assert !fb_object.verify_signature(dummy_fb_params, "12345")
    assert fb_object.verify_signature({:b_param => "5678y", :c_param => "97531t", :a_param => "1234x"}, Digest::MD5.hexdigest("a_param=1234xb_param=5678yc_param=97531t#{FACEBOOK_API_SECRET}"))
  end
  
  # 
  # get_fb_params tests
  def test_should_get_fb_params_from_given_params_hash
    stub_signature_verication # fake verifying of signature -- we test that separately
    assert fb_object.respond_to?(:get_fb_params)
    assert_equal ({}), fb_object.get_fb_params
    assert_equal ({:param_1 => "1234a", :time => two_hours_ago}), fb_object.get_fb_params(dummy_fb_params)
    assert_equal ({:param_1 => "1234a", :time => two_hours_ago}), fb_object.get_fb_params(dummy_fb_params(:another_param_b => "def", :bad_fb_sig_param => "xyz"))
  end
  
  def test_should_return_empty_hash_for_fb_params_if_no_time_param_or_params_are_stale
    stub_signature_verication # fake verifying of signature -- we test that separately
    assert_equal ({:param_1 => "1234a", :time => forty_seven_hours_ago}), fb_object.get_fb_params(dummy_fb_params(:fb_sig_time => forty_seven_hours_ago))
    assert_equal ({}), fb_object.get_fb_params(dummy_fb_params(:fb_sig_time => nil))
    assert_equal ({}), fb_object.get_fb_params(dummy_fb_params(:fb_sig_time => 49.hours.ago.to_f.to_s))
  end
  
  def test_should_return_empty_hash_for_fb_params_if_signature_doesnt_verify
    stub_signature_verication(false)
    assert_equal ({}), fb_object.get_fb_params(dummy_fb_params)
  end
  
  def test_should_check_only_fb_params_against_signature
    fb = fb_object
    fb.expects(:verify_signature).with({:param_1 => "1234a", :time =>two_hours_ago},"1234567890").returns(true)
    fb.get_fb_params(dummy_fb_params(:fb_sig => "1234567890"))
  end
  
  # get_new_session tests
  def test_should_get_new_session_given_auth_token
    assert fb_object.respond_to?(:get_new_session)
    fb = fb_object
    setup_facebook_response
    fb.expects(:post_request).with("facebook.auth.getSession", {:auth_token => "abc123"}).returns(@auth_token_response)
    fb.get_new_session("abc123")
    assert_equal "5f34e11bfb97c762e439e6a5-8055", fb.session_key
    assert_equal "8055", fb.user
  end
  
  def test_should_fail_o_get_new_session_given_bad_auth_token
    assert fb_object.respond_to?(:get_new_session)
    fb = fb_object
    setup_facebook_response
    fb.expects(:post_request).with("facebook.auth.getSession", {:auth_token => "abc123"}).returns(@error_response)
    assert_raise(FacebookUtilities::Facebook::FacebookApiError) { fb.get_new_session("abc123") }
    assert_nil fb.session_key
    assert_nil fb.user
  end
  
  # login_to_app_url tests
  def test_should_return_application_login_page_url
    assert fb_object.respond_to?(:login_to_app_url)
    assert_equal "http://www.facebook.com/login.php?v=1.0&api_key=#{FACEBOOK_API_KEY}", fb_object.login_to_app_url
    assert_equal "http://www.facebook.com/login.php?v=1.0&api_key=#{FACEBOOK_API_KEY}&next=http%3A%2F%2Fsome.other.site", fb_object.login_to_app_url(:next => "http://some.other.site")
    long_login_url = fb_object.login_to_app_url(:auth_token => "abc123", :next => "http://some.other.site", :canvas => true, :skipcookie => false)
    %w(http://www.facebook.com/login.php?v=1.0&api_key  &next=http%3A%2F%2Fsome.other.site  &auth_token=abc123 &canvas=true).each do |r| 
      assert_match Regexp.new(Regexp.escape(r)), long_login_url
    end
    assert_no_match /skipcookie/, long_login_url # should not include params set to false
  end
  
  # app_add_url tests
  def test_should_return_url_to_add_application
    assert fb_object.respond_to?(:add_app_url)
    assert_equal "http://www.facebook.com/add.php?api_key=#{FACEBOOK_API_KEY}", fb_object.add_app_url
    assert_equal "http://www.facebook.com/add.php?api_key=#{FACEBOOK_API_KEY}&next=http%3A%2F%2Fsome.other.site", fb_object.add_app_url(:next => "http://some.other.site")
  end
  
  # in_canvas? tests
  def test_should_return_true_if_in_facebook_canvas
    stub_signature_verication
    assert !fb_object.in_canvas?
    assert fb_object(dummy_fb_params(:fb_sig_in_canvas => "1")).in_canvas?
  end
  
  # in_iframe? tests
  def test_should_return_true_if_in_facebook_iframe
    stub_signature_verication
    assert !fb_object.in_iframe?    
    assert fb_object(dummy_fb_params(:fb_sig_in_iframe => "1")).in_iframe?
  end
  
  # in_frame? tests
  def test_should_return_true_if_in_facebook_frame
    stub_signature_verication
    assert !fb_object.in_frame?
    assert fb_object(dummy_fb_params(:fb_sig_in_canvas => "1")).in_frame?
    assert fb_object(dummy_fb_params(:fb_sig_in_iframe => "1")).in_frame?
  end
  
  # logged_in_to_app? tests
  def test_should_detect_whether_user_is_logged_in_to_app_and_return_user_id_if_they_are
    assert fb_object.respond_to?(:logged_in_to_app?)
    assert !fb_object(dummy_fb_params).logged_in_to_app?
    fb = fb_object
    fb.instance_variable_set(:@user, "1234")
    assert !fb.logged_in_to_app?
    fb.instance_variable_set(:@session_key, "5678")
    assert_equal "1234", fb.logged_in_to_app? # only logged in if both session_key and user are present (NB think php lib only checks user)
  end
  
  # added_app? tests
  def test_should_detect_whether_user_has_added_app
    stub_signature_verication
    assert fb_object.respond_to?(:added_app?)
    assert !fb_object.added_app?
    assert !fb_object(dummy_fb_params(:fb_sig_added => "0")).added_app?
    assert fb_object(dummy_fb_params(:fb_sig_added => "1")).added_app?
  end
  
  # call tests  
  def test_should_call_facebook_with_given_method_and_params_and_return_parsed_xml_response_from_calling_facebook_method
    setup_facebook_response
    fb = fb_object
    assert fb.respond_to?(:call)
    fb.expects(:post_request).with("facebook.users.getLoggedInUser", {:uid => "12345"}).returns(@group_members_response)
    parsed_response = fb.call(:users_get_logged_in_user, {:uid => "12345"})
    assert_kind_of Hash, parsed_response
    assert_kind_of Array, parsed_response["members"]
    assert_equal 4, parsed_response["members"].first["uid"].size
  end
  
  def test_should_raise_exception_if_facebook_returns_an_error_to_method_call
    setup_facebook_response
    fb = fb_object
    fb.expects(:post_request).with("facebook.users.getLoggedInUser", {:uid => "12345"}).returns(@error_response)
    assert_raise(FacebookUtilities::Facebook::FacebookApiError) { fb.call(:users_get_logged_in_user, {:uid => "12345"}) }
  end
  
  # post_request tests 
  def test_should_post_request_to_facebook_and_insert_required_parameters
    fb = fb_object
    fb.instance_variable_set(:@session_key, "abc123")
    assert fb.respond_to?(:post_request)
    Time.expects(:now).returns(123.4) # Mock current time
    base_params = { "api_key" => FACEBOOK_API_KEY, 
                        "call_id" => "123.4", 
                        "method" => "facebook.users.getLoggedInUser", 
                        "v" => "1.0",
                        "session_key" => "abc123",
                        "uid" => "12345" }
    expected_params = base_params.merge({"sig" => fb_object.signature_from(base_params)})

    fb.expects(:post_http_request).with("api.facebook.com", "/restserver.php", expected_params).returns("hello world")
    
    assert_equal "hello world", fb.post_request("facebook.users.getLoggedInUser", {:uid => "12345"})    
  end
  
  def test_should_return_false_in_test_environment_for_post_http_request_without_doing_anything
    Net::HTTP.expects(:new).never
    fb_object.post_request("facebook.users.someMethod", {:some_attribute => "12345"})
  end
  
  # method_missing tests
  def test_should_call_with_unknown_facebook_method
    fb = fb_object{}
    dummy_params = {:dummy_1 => "foo", :dummy_2 => "bar"}
    fb.expects(:call).with('some_unknown_method', dummy_params).returns("hello world")
    assert_equal "hello world", fb.fb_some_unknown_method(dummy_params)
  end
  
  def test_should_not_call_with_other_unknown_method
    assert_raise(NoMethodError) { fb_object.some_other_unknown_method({}) }
  end
    
  private
  def dummy_fb_params(options={})
    {:fb_sig_param_1 => "1234a", :another_param_a => "abc", :fb_sig_time => two_hours_ago}.merge(options)
  end
  
  def fb_object(params={})
    FacebookUtilities::Facebook.new(params)
  end
  
  def stub_signature_verication(result=true)
    FacebookUtilities::Facebook.any_instance.stubs(:verify_signature).returns(result)
  end
  
  def two_hours_ago
    @two_hours_ago ||=2.hours.ago.to_f.to_s
  end
  
  def forty_seven_hours_ago
    @forty_seven_hours_ago ||=47.hours.ago.to_f.to_s
  end
  
  def setup_facebook_response
    @user_info_response = <<-EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <users_getLoggedInUser_response xmlns="http://api.facebook.com/1.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://api.facebook.com/1.0/ http://api.facebook.com/1.0/facebook.xsd">1234567</users_getLoggedInUser_response>
    EOF
    
    @group_members_response = <<-EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <groups_getMembers_response xmlns="http://api.facebook.com/1.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://api.facebook.com/1.0/ http://api.facebook.com/1.0/facebook.xsd">
        <members list="true">
          <uid>4567</uid>
          <uid>5678</uid>
          <uid>6789</uid>
          <uid>7890</uid>
        </members>
        <admins list="true">
          <uid>1234567</uid>
        </admins>
        <officers list="true"/>
        <not_replied list="true"/>
      </groups_getMembers_response>
    EOF
    
    @auth_token_response = <<-EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <auth_getSession_response
        xmlns="http://api.facebook.com/1.0/"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://api.facebook.com/1.0/ http://api.facebook.com/1.0/facebook.xsd">
          <session_key>5f34e11bfb97c762e439e6a5-8055</session_key>
          <uid>8055</uid>
          <expires>1173309298</expires>
      </auth_getSession_response>
    EOF
    
    @error_response = <<-EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <error_response xmlns="http://api.facebook.com/1.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://api.facebook.com/1.0/ http://api.facebook.com/1.0/facebook.xsd">
        <error_code>5</error_code>
        <error_msg>Unauthorized source IP address (ip was: 10.1.2.3)</error_msg>
        <request_args list="true">
          <arg>
            <key>method</key>
            <value>facebook.friends.get</value>
          </arg>
          <arg>
            <key>session_key</key>
            <value>373443c857fcda2e410e349c-i7nF4PqX4IW4.</value>
          </arg>
          <arg>
            <key>api_key</key>
            <value>0289b21f46b2ee642d5c42145df5489f</value>
          </arg>
          <arg>
            <key>call_id</key>
            <value>1170813376.3544</value>
          </arg>
          <arg>
            <key>v</key>
            <value>1.0</value>
          </arg>
          <arg>
            <key>sig</key>
            <value>570dcc2b764578af350ea1e1622349a0</value>
          </arg>
        </request_args>
      </error_response>
    EOF
     
  end
  
end

# This is a dummy controller which includes FacebookUtilities::ControllerUtilities. NB we use exclusively posts to test this as that's what Facebook does
class DummyFacebookController < ActionController::Base
  include FacebookUtilities::ControllerUtilities
  before_filter :require_fb_frame, :only => [:guest]
  before_filter :require_logged_in_to_fb_app, :only => [:show]
  before_filter :require_added_fb_app, :only => [:member]
  
  def guest
    render :text => "called from facebook"
  end
  
  def show
    render :text => "User is logged-in to app"
  end
  
  def member
    render :text => "User has added app"
  end
  
  def redirect_action
    fb_redirect_to params[:url]
  end
  
  # used in dummy controller test to get access to private methods
  def priv_method(meth_name, args=nil)
    args ? self.send(meth_name, args) : self.send(meth_name)
  end
  
  # Re-raise errors caught by the controller.
  def rescue_action(e) 
    raise e 
  end
end

class DummyFacebookControllerTest < Test::Unit::TestCase

  def setup
    @controller = DummyFacebookController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # require_fb_frame tests
  def test_should_require_request_to_be_made_from_fb_frame
    assert !@controller.respond_to?(:require_fb_frame)
    assert @controller.respond_to?(:require_fb_frame, true)
    post :guest
    assert_redirected_to "http://www.facebook.com/login.php?v=1.0&api_key=#{FACEBOOK_API_KEY}"
    FacebookUtilities::Facebook.any_instance.expects(:in_frame?).returns(true)
    post :guest
    assert_equal "called from facebook", @response.body #redirects_to Facebook login page
  end
  
  # facebook tests
  def test_should_access_facebook_object_through_private_facebook_method_and_store_as_instance_variable
    assert !@controller.respond_to?(:facebook)
    assert @controller.respond_to?(:facebook, true)
    @controller.expects(:params).returns({})
    facebook_object = @controller.priv_method(:facebook)
    assert_kind_of FacebookUtilities::Facebook, facebook_object
    assert_equal facebook_object, @controller.instance_variable_get(:@facebook) 
  end
  
  def test_should_pass_params_to_facebook_object_when_instantiating
    @controller.expects(:params).returns({:param_a => "foo", :param_b => "bar"})
    FacebookUtilities::Facebook.expects(:new).with({:param_a => "foo", :param_b => "bar"})
    @controller.priv_method(:facebook)
  end
  
  # fb_redirect_to tests
  def test_should_have_private_method_fb_redirect_to
    assert !@controller.respond_to?(:fb_redirect_to)
    assert @controller.respond_to?(:fb_redirect_to, true)
  end
  
  def test_should_redirect_to_given_url_when_not_in_fb
    post :redirect_action, {:url => "http://www.dummy.com"}
    assert_redirected_to "http://www.dummy.com"
  end
  
  def test_should_send_fb_type_redirect_when_in_fb_canvas
    FacebookUtilities::Facebook.any_instance.expects(:in_canvas?).returns(true)
    post :redirect_action, {:url => "http://www.dummy.com"}
    assert_equal '<fb:redirect url="http://www.dummy.com" />', @response.body
  end
  
  # This is how php lib does it, handles situation in iframe and external website. Obviously doesn't allow for non-js browsers, but can you use them on FB?
  def test_should_send_javascript_redirect_if_not_in_canvas_and_redirecting_to_fb_url
    post :redirect_action, {:url => "http://some.facebook.com/address"}
    assert_equal "<script type=\"text/javascript\">\ntop.location.href = \"http://some.facebook.com/address\";\n</script>", @response.body
  end
      
  # require_logged_in_to_fb_app tests  
  def test_should_require_user_to_have_logged_in_to_fb_app_and_redirect_if_not
    assert !@controller.respond_to?(:require_logged_in_to_fb_app)
    assert @controller.respond_to?(:require_logged_in_to_fb_app, true) # require_logged_in_to_fb_app is a private method
    FacebookUtilities::Facebook.any_instance.expects(:logged_in_to_app?).returns(true)
    post :show
    assert_equal "User is logged-in to app", @response.body
    FacebookUtilities::Facebook.any_instance.expects(:logged_in_to_app?).returns(false)
    FacebookUtilities::Facebook.any_instance.expects(:login_to_app_url).returns("http://some.other.url")
    post :show
    assert_redirected_to "http://some.other.url" # redirects using redirect_to if external url
  end
  
  def test_should_redirect_to_facebook_login_page_with_canvas_param_set_only_if_in_facebook_frame
    FacebookUtilities::Facebook.any_instance.expects(:in_frame?).returns(false)
    post :show
    assert_equal "<script type=\"text/javascript\">\ntop.location.href = \"http://www.facebook.com/login.php?v=1.0&api_key=#{FACEBOOK_API_KEY}\";\n</script>", @response.body
    FacebookUtilities::Facebook.any_instance.expects(:in_frame?).returns(true)
    post :show
    assert_equal "<script type=\"text/javascript\">\ntop.location.href = \"http://www.facebook.com/login.php?v=1.0&api_key=#{FACEBOOK_API_KEY}&canvas=true\";\n</script>", @response.body
  end
  
  # require_added_fb_app tests
  def test_should_require_user_to_have_added_fb_app_and_redirect_if_not
    assert !@controller.respond_to?(:require_added_fb_app)
    assert @controller.respond_to?(:require_added_fb_app, true) # require_added_fb_app is a private method
    FacebookUtilities::Facebook.any_instance.expects(:added_app?).returns(true)
    post :member
    assert_equal "User has added app", @response.body
    FacebookUtilities::Facebook.any_instance.expects(:added_app?).returns(false)
    post :member
    assert_equal "<script type=\"text/javascript\">\ntop.location.href = \"http://www.facebook.com/add.php?api_key=#{FACEBOOK_API_KEY}\";\n</script>", @response.body
  end
  
end