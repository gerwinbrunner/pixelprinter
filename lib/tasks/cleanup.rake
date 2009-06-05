namespace :cleanup do
  desc 'Delete old template versions'
  task :print_template_versions => :environment do 
    tmpls = PrintTemplateVersion.delete_all("created_at < DATE_SUB(UTC_TIMESTAMP(), INTERVAL 3 MONTH)")
    # puts "Deleted #{tmpls.size} templates."
  end
end
