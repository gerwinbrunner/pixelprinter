ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class ActiveSupport::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all


  protected
  
  def order(file = 'example_order.xml')
    order_xml = load_data(file)
    ShopifyAPI::Order.new(Hash.from_xml(order_xml)['order'])
  end

  def shop(file = 'shop.xml', overwrites = {})
    shop_xml = load_data(file)
    ShopifyAPI::Shop.new(Hash.from_xml(shop_xml)['shop'].merge(overwrites))
  end
  
  def login_session(shop_name)
    Shop.stubs(:find_by_name).returns(shops(shop_name))
    {:shopify => ShopifyAPI::Session.new(shop_name.to_s, 'somerandomtoken')}
  end

  # Custom Assertions
  def assert_response_include(code)
    assert_block("Expected the response <#{@response.body}> to include the following content: <#{code}>") do
      @response.body.include?(code)
    end
  end
  
  
  private

  def load_data(file)
    File.read("#{Rails.root}/test/data/#{file}")
  end
end
