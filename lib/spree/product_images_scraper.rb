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
      if can_scrape_images?
        scrape_images
      else
        if product.images.exists?
          log.info "product.images.exists #{product.id}"
        elsif !product_url.present?
          log.info "product url no present: #{product_url.present?}"
        end 
      end
    end

    def scrape_images
      page = Nokogiri::HTML(open(URI.join(scraper.catalog_url, product_url)))
      image_links = page.css(scraper.product_images_selector)
      if image_links.length > 0
        image_links.each_with_index do |image_link, image_index|
          scrape_image(image_link[:href], image_index)
        end
      else
        log.info "not images for product #{product_url}"
      end
    end

    def scrape_image(image_url, image_index)
      image_file = open(URI.join(scraper.catalog_url, URI.encode(image_url)))
      def image_file.original_filename
        base_uri.path.split('/').last
      end
      log.info "Parsing images for product #{product.name}"
      image = product.images.create(:attachment => image_file, :alt => product.name + '-' + (image_index + 1).to_s)
      image_file.close
    end

    protected

    def can_scrape_images?
      scraper.product_images_selector.present? && product_url.present? && !product.images.exists?
    end

  end
end
