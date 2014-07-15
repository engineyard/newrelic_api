require 'active_resource'
require 'active_resource_associations'

# = New Relic REST API
#
# This is a helper module for working with the New Relic API's XML interface.  Requires Rails 2.0 or later to be loaded.
#
# Can also be used as a script using script/runner.
#
# In this version of the api, authentication is handled using your account API key, available in your Account settings
# in rpm.newrelic.com[link:https://rpm.newrelic.com].
# Log in, click Account at the top of the page and check the "Make my account data accessible" checkbox.  An
# API key will appear.
#
# Refer to the README file for details and examples on the REST API.
#
# == Examples
#
#   # Fetching the list of applications for an account
#   NewRelicApi::Application.all
#
#   # Finding an application by name
#   NewRelicApi::Application.find(:first, :params => {:filter => {:name => 'My App'}})
#

module NewRelicApi

  class << self
    attr_accessor :api_key, :ssl, :host, :port, :proxy

    # Resets the base path of all resources.  This should be called when overridding the newrelic.yml settings
    # using the ssl, host or port accessors.
    def reset!
      @classes.each {|klass| klass.reset!} if @classes
      NewRelicApi::Account.site_url
    end


    def track_resource(klass) #:nodoc:
      (@classes ||= []) << klass
    end
  end

  class BaseResource < ActiveResource::Base #:nodoc:
    include ActiveResourceAssociations

    class << self

      def inherited(klass) #:nodoc:
        NewRelicApi.track_resource(klass)
      end

      def headers
        raise "api_key required" unless NewRelicApi.api_key
        {'X-Api-Key' => NewRelicApi.api_key}
      end

      def site_url
        host = NewRelicApi.host || 'api.newrelic.com'
        port = NewRelicApi.port || 443
        "#{port == 443 ? 'https' : 'http'}://#{host}:#{port}"
      end

      def reset!
        self.site = self.site_url
      end

      def proxy
        NewRelicApi.proxy
      end
    end

    self.format = :json
    self.site = self.site_url
    self.proxy = self.proxy
    self.prefix = '/v2/'
  end

  # An account contains your basic account information.
  #
  # Find Accounts
  #
  #   NewRelicApi::Account.find(:first) # find account associated with the api key
  #   NewRelicApi::Account.find(44)     # find individual account by ID
  #
  class Account < BaseResource
  end

  class JsonApiFormatter
    include ActiveResource::Formats::JsonFormat

    def initialize(resource_name)
      @resource_name = resource_name
    end

    def decode(json)
      ActiveResource::Formats::JsonFormat.decode(json)[@resource_name]
    end
  end

end

require_relative 'new_relic_api/application'
require_relative 'new_relic_api/application_host'
require_relative 'new_relic_api/application_instance'
require_relative 'new_relic_api/server'
require_relative 'new_relic_api/user'
