class CreatePrintTemplateVersions < ActiveRecord::Migration
  def self.up
    create_table :print_template_versions do |t|
      t.integer  :print_template_id
      t.text     :body
      t.datetime :created_at
      t.integer  :version, :default => 0
      t.string   :snapshot
    end
  end

  def self.down
    drop_table :print_template_versions
  end
end
