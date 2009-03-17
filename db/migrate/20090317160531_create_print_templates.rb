class CreatePrintTemplates < ActiveRecord::Migration
  def self.up
    create_table :print_templates do |t|
      t.integer :shop_id
      t.text :body
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :print_templates
  end
end