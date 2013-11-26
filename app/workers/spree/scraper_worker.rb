require 'sidekiq'
module Spree
  class ScraperWorker
    include ::Sidekiq::Worker
    sidekiq_options :queue => :scraper, :backtrace => true

    def perform(scraper_id)
      scraper = Spree::Scraper.find(scraper_id)
      Spree::BaseScraper.new(scraper).scrape
    end
  end
end
