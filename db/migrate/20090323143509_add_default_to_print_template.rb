class AddDefaultToPrintTemplate < ActiveRecord::Migration
  def self.up
    add_column :print_templates, :default, :boolean, :default => false
  end

  def self.down
    remove_column :print_templates, :default
  end
end
