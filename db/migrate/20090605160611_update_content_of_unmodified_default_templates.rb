class UpdateContentOfUnmodifiedDefaultTemplates < ActiveRecord::Migration
  TEMPLATES = %w( invoice packing_slip variable_reference )

  NEW_CONTENTS = TEMPLATES.inject({}) do |memo, template|
                   memo[template] = File.read("#{RAILS_ROOT}/db/printing/#{template}.liquid")
                   memo
                 end
                          
  MD5 = {"invoice"            => "3cbe75be4e5559a0643581bb48c43222", 
         "packing_slip"       => "84054e0b1b3659a969c0d3b984aff8e7", 
         "variable_reference" => "caa1eb749f63a296ebddf9019ba188c8" }
                 
  def self.up
    transaction do
      TEMPLATES.each do |template|
        execute "UPDATE print_templates SET body = #{NEW_CONTENTS[template].inspect} WHERE MD5(body) IN (#{MD5[template].join(', ')})"
      end
    end    
  end

  def self.down
    # can't be reversed
  end
end