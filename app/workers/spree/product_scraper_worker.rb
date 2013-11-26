require 'sidekiq'
module Spree
  class ProductScraperWorker
    include ::Sidekiq::Worker
    sidekiq_options :queue => :scraper, :backtrace => true

    def perform(taxon_id, scraper_id, taxon_url)
      taxon = Spree::Taxon.find(taxon_id)
      scraper = Spree::Scraper.find(scraper_id)
      Spree::ProductsScraper.new(taxon, scraper, taxon_url).scrape
    end
  end
end
