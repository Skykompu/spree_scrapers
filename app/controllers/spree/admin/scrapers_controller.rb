module Spree
  module Admin
    class ScrapersController < ResourceController
      def scrape
        Spree::ScraperWorker.perform_async(params[:id])
        redirect_to admin_scrapers_path, :notice => Spree.t(:scraping_started)
      end
    end
  end
end
