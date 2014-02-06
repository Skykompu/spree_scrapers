class AddProductImagesSelectorToScrapers < ActiveRecord::Migration
  def change
    add_column :spree_scrapers, :product_images_selector, :string
  end
end
