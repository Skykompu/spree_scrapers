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
      if scraper.products_paging_url_suffix.present?
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
        product_links = scrape_products(products_url)
        current_page += 1
      end while product_links.present?
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
      product_links
    end

    def scrape_product(product_url, product_name)
      log.info "Parsing product #{product_name}"
      page = Nokogiri::HTML(open(URI.join(scraper.catalog_url, product_url)))
      product_description_element = page.css(scraper.product_description_selector)
      product_description = product_description_element.text
      # don't know why but "first_or_create" not working
      unless (product = Spree::Product.where(name: product_name).first)
        product = Spree::Product.create!(name: product_name, description: product_description, price: 1, shipping_category_id: Spree::ShippingCategory.first.id, sku: [taxon.id, SecureRandom.hex(2)].join)
        taxon.products << product
      end
      scrape_properties(product, page)
    end

    def scrape_properties(product, product_page)
      property_value_elements = product_page.css(scraper.property_value_selector)
      product_page.css(scraper.property_name_selector).each_with_index do |property_element, index|
        property = Spree::Property.where(name: property_element.text).first_or_create!(presentation: property_element.text)
        product.product_properties.where(property_id: property.id).first_or_create!(value: property_value_elements[index].text)
      end
    end
  end
end
