class AddIndexToPrintTemplatesShopId < ActiveRecord::Migration
  def self.up
    add_index :print_templates, :shop_id
  end

  def self.down
    remove_index :print_templates, :shop_id
  end
end
