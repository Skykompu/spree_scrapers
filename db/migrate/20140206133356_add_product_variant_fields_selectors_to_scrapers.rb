class AddProductVariantFieldsSelectorsToScrapers < ActiveRecord::Migration
  def change
    add_column :spree_scrapers, :product_variant_images_selector, :string
  end
end
