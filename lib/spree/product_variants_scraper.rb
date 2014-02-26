require 'nokogiri'
require 'open-uri'

module Spree
  class ProductVariantsScraper < BaseScraper
    attr_reader :product, :product_url

    def initialize(product, scraper, product_url)
      super(scraper)
      @product = product
      @product_url = product_url
    end

    def scrape
      log.info "Parsing variants for product #{product.name}"
      if can_scrape_variants?
        scrape_variants
      end
    end

    def scrape_variants
      page = Nokogiri::HTML(open(URI.join(scraper.catalog_url, product_url)))
      page.css(scraper.product_variants_selector).each do |variant_element|
        variant = product.variants.create!(price: 1, sku: [product.taxons.first.id, SecureRandom.hex(2)].join)
        scrape_images(variant, variant_element)
        scrape_options(variant, variant_element)
      end
    end

    def scrape_images(variant, variant_element)
      image_links = variant_element.css(scraper.product_variant_images_selector)
      image_links.each_with_index do |image_link, image_index|
        scrape_image(image_link[:href], image_index, variant)
      end
    end

    def scrape_image(image_url, image_index, variant)
      image_file = open(URI.join(scraper.catalog_url, image_url))
      def image_file.original_filename
        base_uri.path.split('/').last
      end
      image = variant.images.create(:attachment => image_file, :alt => product.name + '-' + (image_index + 1).to_s)
      image_file.close
    end

    def scrape_options(variant, variant_element)
      option_value_elements = variant_element.css(scraper.product_variant_option_values_selector).map(&:text).map(&:strip)
      variant_element.css(scraper.product_variant_option_types_selector).map(&:text).map(&:strip).each_with_index do |option_name, index|
        if valid_option?(option_name)
          option_type = Spree::OptionType.where(name: option_name).first_or_create!(presentation: option_name)
          product.product_option_types.where(option_type_id: option_type.id).first_or_create!
          variant.option_values << Spree::OptionValue.where(name: option_value_elements[index]).first_or_create!(name: option_value_elements[index], presentation: option_value_elements[index], option_type_id: option_type.id) if option_value_elements[index]
        end
      end
    end

    def valid_option?(option_name)
      option_name.present? # this could be overridden
    end

    protected

    def can_scrape_variants?
      (scraper.product_variant_images_selector.present? || scraper.product_variants_selector.present?) && product_url.present? && !product.variants.exists?
    end

  end
end
