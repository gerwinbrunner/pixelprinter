class CreateShopUrlRemoveShopName < ActiveRecord::Migration
  def self.up
    remove_column :shops, :name
    add_column    :shops, :url, :string
    add_index     :shops, :url
  end

  def self.down
    add_column    :shops, :name, :string
    remove_column :shops, :url
    remove_index  :shops, :url
  end
end
