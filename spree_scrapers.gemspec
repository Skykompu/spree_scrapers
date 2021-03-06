# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_scrapers'
  s.version     = '2.1.1'
  s.summary     = 'Allows to scrape taxonomy tree and products from external sites by using configurable Scraper objects'
  s.description = 'Allows to scrape taxonomy tree and products from external sites by using configurable Scraper objects'
  s.required_ruby_version = '>= 1.9.3'

  s.author    = 'Igor Petrov'
  # s.email     = 'you@example.com'
  # s.homepage  = 'http://www.spreecommerce.com'

  #s.files       = `git ls-files`.split("\n")
  #s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'solidus', '~> 1.2.0'
  s.add_dependency 'sidekiq'
  s.add_dependency 'nokogiri'

  s.add_development_dependency 'capybara', '~> 2.1'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl', '~> 4.2'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails',  '~> 2.13'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
end
