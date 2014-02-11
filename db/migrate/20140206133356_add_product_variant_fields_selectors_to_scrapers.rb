class AddProductVariantFieldsSelectorsToScrapers < ActiveRecord::Migration
  def change
    add_column :spree_scrapers, :product_variant_images_selector, :string
    add_column :spree_scrapers, :product_variant_option_types_selector, :string
    add_column :spree_scrapers, :product_variant_option_values_selector, :string
  end
end
