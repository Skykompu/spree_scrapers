class AddProductsPagingUrlSuffixToSpreeScrapers < ActiveRecord::Migration
  def change
    add_column :spree_scrapers, :products_paging_url_suffix, :string
  end
end
