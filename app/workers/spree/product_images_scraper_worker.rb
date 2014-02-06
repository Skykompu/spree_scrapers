require 'sidekiq'
module Spree
  class ProductImagesScraperWorker
    include ::Sidekiq::Worker
    sidekiq_options :queue => :scraper, :backtrace => true

    def perform(product_id, scraper_id, product_url)
      product = Spree::Product.find(product_id)
      scraper = Spree::Scraper.find(scraper_id)
      Spree::ProductImagesScraper.new(product, scraper, product_url).scrape
    end
  end
end
