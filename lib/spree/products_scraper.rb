require 'nokogiri'
require 'open-uri'

module Spree
  class ProductsScraper < BaseScraper
    attr_reader :taxon, :taxon_url

    def initialize(taxon, scraper, taxon_url)
      super(scraper)
      @taxon = taxon
      @taxon_url = taxon_url
    end

    def scrape
      log.info "Parsing products of #{taxon.name}"
      if scraper.products_paging_url_suffix #.present?
        scrape_paginated_products
      else
        scrape_products
      end
    end

    def scrape_paginated_products
      current_page = 1
      begin
        if current_page > 1
            products_url = URI.join(scraper.catalog_url, taxon_url, scraper.products_paging_url_suffix + current_page.to_s)
        end
       page = scrape_products(products_url)
       current_page += 1
      end while (page.css('.ctrlNext.no-active').length == 0)
    rescue OpenURI::HTTPError => e
        log.error "Error occured (at url #{products_url}): #{e.message}"
        return
    end

    def scrape_products(products_url=nil)
      if products_url
        page = Nokogiri::HTML(open(products_url))
      else
        page = Nokogiri::HTML(open(URI.join(scraper.catalog_url, taxon_url)))
      end
      product_links = page.css(scraper.products_selector)
      product_links.each do |product_link|
        scrape_product(product_link[:href], product_link.text)
      end
      page
    end

    def scrape_product(product_url, product_name)
      if product = Spree::Product.where(name: product_name).first
        log.info "Parsing product exist #{product_name}"
        scrape_images(product, product_url) 
      else
        log.info "product not exist #{product_name}"
      end
    end

    def scrape_images(product, product_url)
        ProductImagesScraperWorker.perform_async(product.id, scraper.id, product_url)
    end

  end
end
