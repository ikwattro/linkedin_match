# encoding: utf-8
cbm_dir = File.expand_path('../cbm', __FILE__)
$:.unshift(cbm_dir) unless $:.include? cbm_dir

require 'sidekiq/middleware/server/unique_jobs'
require 'sidekiq/middleware/client/unique_jobs'

Sidekiq.configure_server do |config|
  config.redis = { :url => ENV['REDISTOGO_URL'], :size => 10}
  config.server_middleware do |chain|
    chain.add Sidekiq::Middleware::Server::UniqueJobs
  end
end

Sidekiq.configure_client do |config|
  config.redis = { :url => ENV['REDISTOGO_URL'] , :size => 10}
  config.client_middleware do |chain|
    chain.add Sidekiq::Middleware::Client::UniqueJobs
  end
end

Geocoder.configure do |config|
  config.lookup = :yahoo
  config.timeout = 30
  config.cache = Redis.connect(:url => ENV['REDISTOGO_URL'])
end

LinkedIn.configure do |config|
  config.token = (ENV['CONSUMER_KEY'] || "udmw68f7t3om")
  config.secret = (ENV['CONSUMER_SECRET'] || "41OHptpc1oFOnI9n")
  config.default_profile_fields = ['id', 'first-name', 'last-name', 'educations', 'positions', 'skills', 'location',
                                   'picture-url', 'certifications']
end

$neo_server = Neography::Rest.new

require 'enumerator'
require 'util'

require 'models/user'
require 'models/criteria'
require 'models/location'
require 'models/path'
require 'models/skill'

require 'jobs/import_linkedin_profile'
require 'jobs/import_linkedin_connections'
