require 'nokogiri'
require 'open-uri'

module Spree
  class BaseScraper
    #include Capybara::DSL

    attr_reader :scraper, :log

    def initialize(scraper)
      @scraper = scraper
      @log = Logger.new(STDOUT)
    end

    def scrape
      taxonomy = Spree::Taxonomy.where(name: scraper.catalog_url).first_or_create!
      scrape_taxons(taxonomy)
    end

    def scrape_taxons(taxonomy)
      log.info "Parsing #{scraper.catalog_url}"
      page = Nokogiri::HTML(open(scraper.catalog_url))
      page.css(scraper.taxons_selector).each do |taxon_link|
        # don't know why but "first_or_create" not working
        unless (taxon = taxonomy.taxons.where(name: taxon_link.text).first)
          taxon = Spree::Taxon.create!(parent_id: taxonomy.root.id, name: taxon_link.text, taxonomy_id: taxonomy.id)
        end
        scrape_taxon(taxon, taxon_link[:href])
      end
    end

    def scrape_taxon(taxon, taxon_url)
      log.info "Parsing taxon #{taxon.name}"
      scrape_subtaxons(taxon, taxon_url)
    end

    def scrape_subtaxons(taxon, taxon_url)
      page = Nokogiri::HTML(open(URI.join(scraper.catalog_url, taxon_url)))
      if (subtaxon_links = page.css(scraper.subtaxons_selector)).present?
        subtaxon_links.each do |subtaxon_link|
          # don't know why but "first_or_create" not working
          unless (subtaxon = taxon.taxonomy.taxons.where(name: subtaxon_link.text).first)
            subtaxon = Spree::Taxon.create(taxonomy_id: taxon.taxonomy_id, name: subtaxon_link.text, parent_id: taxon.id)
          end
          scrape_taxon(subtaxon, subtaxon_link[:href])
        end
      else
        scrape_products(taxon, taxon_url)
      end
    end

    def scrape_products(taxon, taxon_url)
        ProductScraperWorker.perform_async(taxon.id, scraper.id, taxon_url)
    end
  end
end
