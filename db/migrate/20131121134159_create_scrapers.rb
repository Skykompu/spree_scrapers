class CreateScrapers < ActiveRecord::Migration
  def change
    create_table :spree_scrapers do |t|
      t.string :catalog_url
      t.string :taxons_selector
      t.string :subtaxons_selector
      t.string :products_selector
      t.string :product_description_selector
      t.string :property_name_selector
      t.string :property_value_selector
      t.timestamps
    end
  end
end
