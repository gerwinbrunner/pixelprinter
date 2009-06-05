require 'test_helper'

class PrintTemplateVersionTest < ActiveSupport::TestCase

  should "delete templates older than 3 months" do
    PrintTemplateVersion.create :created_at => 2.weeks.ago
    PrintTemplateVersion.create :created_at => 3.months.ago + 1.days
    PrintTemplateVersion.create :created_at => 10.months.ago
                         
    assert_difference "PrintTemplateVersion.count", -1 do 
      PrintTemplateVersion.delete_all("created_at < DATE_SUB(UTC_TIMESTAMP(), INTERVAL 3 MONTH)")
    end
  end
end