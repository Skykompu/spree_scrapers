require 'nokogiri'
require 'open-uri'

module Spree
  class ProductImagesScraper < BaseScraper
    attr_reader :product, :product_url

    def initialize(product, scraper, product_url)
      super(scraper)
      @product = product
      @product_url = product_url
    end

    def scrape
      log.info "Parsing images for product #{product.name}"
      if can_scrape_images?
        scrape_images
      end
    end

    def scrape_images
      page = Nokogiri::HTML(open(URI.join(scraper.catalog_url, product_url)))
      image_links = page.css(scraper.product_images_selector)
      image_links.each_with_index do |image_link, image_index|
        scrape_image(image_link[:href], image_index)
      end
    end

    def scrape_image(image_url, image_index)
      image_file = open(URI.join(scraper.catalog_url, image_url))
      def image_file.original_filename
        base_uri.path.split('/').last
      end
      image = product.images.create(:attachment => image_file, :alt => product.name + '-' + (image_index + 1).to_s)
    end

    protected

    def can_scrape_images?
      scraper.product_images_selector.present? && product_url.present? && !product.images.exists?
    end

  end
end
