Deface::Override.new(:virtual_path => "spree/admin/shared/_menu",
                     :name => "scrapers_admin_tab",
                     :insert_bottom => "[data-hook='admin_tabs']",
                     :text => "<%= tab(:scrapers, :icon => 'icon-file') %>",
                     :disabled => false)
