ActiveRecord::Base.logger = Logger.new(STDOUT)

class UpdateContentOfUnmodifiedDefaultTemplates < ActiveRecord::Migration
  TEMPLATES    = %w( invoice packing_slip variable_reference )

  NEW_CONTENTS = TEMPLATES.inject({}) do |memo, template|
                   memo[template] = File.read("#{RAILS_ROOT}/db/printing/#{template}.liquid")
                   memo
                 end

  # Hashes of old default template contents that are save to overwrite, because they haven't been changed by the user yet
  ORIGINAL_MD5 = { "invoice"            => ["3cbe75be4e5559a0643581bb48c43222", "cb44126c6c299701fef22058670ae34f", "77975982a6f49bc2eebf3248f4aaddbf"],
                   "packing_slip"       => ["84054e0b1b3659a969c0d3b984aff8e7", "cbaba8dfbcc4b64955b7ed12c708a4ea", "5546720aa939062cae7b63861663c331"], 
                   "variable_reference" => ["caa1eb749f63a296ebddf9019ba188c8", "328811bd3ee651c26f1e1c46bc8850eb", "b1775d4c8c17320f45a3d40601562f02"]
                 }
                 
  def self.up
    transaction do
      TEMPLATES.each do |template|
        PrintTemplate.update_all(["body = ?", NEW_CONTENTS[template]], ["md5(body) IN (?)", ORIGINAL_MD5[template]])
      end
    end    
  end

  def self.down
    # can't be reversed
  end
end