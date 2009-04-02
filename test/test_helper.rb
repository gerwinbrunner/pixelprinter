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


  # Checks if all the variables used in the +template+ are available in the +liquid_hash+.
  # Makes sure that the values for the variables from +liquid_hash+ occur (somewhere) in the rendered template.
  #
  def assert_render_liquid(template, liquid_hash)
    # extract all the variable names and filters from the template
    used_variables_with_filters = template.body.scan(/\{\{ *([^\}]*) *\}\}/).flatten
    
    # map variable names to applied filters
    variables_to_filters = {}
    used_variables_with_filters.each do |variable_with_filter|
      variable_and_filters = variable_with_filter.split(/ ?\| ?/)
      variables_to_filters[variable_and_filters.first] = variable_and_filters[1..-1]
    end

    # resolve nested variables, e.g. 'order.customer.name' to ['order', 'customer', 'name']
    used_variables = {}
    variables_to_filters.keys.each do |variable|
      resolved_variable = (variable =~ /\./ ? variable.scan(/(\w+)\.?/).flatten : variable)
      used_variables[variable] = resolved_variable
    end
    
    rendered_template = template.render(liquid_hash)

    errors = {}
    used_variables.each do |variable, resolved|
      # get the value for the variable name from liquid_hash (also for nested variables)
      value = \
        if resolved.is_a?(Enumerable)
          resolved.inject(liquid_hash){|memo, name| memo[name] rescue memo.send(name) rescue nil}
        else
          liquid_hash[resolved]
        end
      value = apply_filters(value.to_s, variables_to_filters[variable])
      # check if (filtered) value occurs anywhere in template
      errors[variable] = value unless rendered_template.include?(value)
    end
    error_string = errors.map { |var, value| "<#{var.to_a.join('.')} = #{value}>" }.join(", ")
    assert_block("Expected template to render #{error_string}\n\nRendered template:\n\n#{rendered_template}\n\nOriginal template:\n\n#{template.body}") do
      errors.empty?
    end
  end
  
  private

  # Add additional filters to be used with liquid here
  class AvailableFilters
    extend EmailMoneyFilter
    extend MoneyFilter
  end

  def apply_filters(value, filters)
    filters.inject(value) { |memo, filter| AvailableFilters.send(filter.strip, memo) }
  end
  
end
