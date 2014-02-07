class AddProductVariantsSelectorToScrapers < ActiveRecord::Migration
  def change
    add_column :spree_scrapers, :product_variants_selector, :string
  end
end
