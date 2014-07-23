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

      def find(*arguments, api_key)
        scope   = arguments.slice!(0)
        options = arguments.slice!(0) || {}
        api_key ||= NewRelicApi.api_key

        case scope
          when :all   then find_every(options, api_key)
          when :first then find_every(options, api_key).first
          when :last  then find_every(options, api_key).last
          when :one   then find_one(options, api_key)
          else             find_single(scope, options, api_key)
        end
      end

      def find_every(options, api_key)
        request_headers = authorize_headers(api_key)
        begin
          case from = options[:from]
          when Symbol
            instantiate_collection(get(from, options[:params]), options[:params])
          when String
            path = "#{from}#{query_string(options[:params])}"
            instantiate_collection(format.decode(connection.get(path, request_headers).body) || [], options[:params])
          else
            prefix_options, query_options = split_options(options[:params])
            path = collection_path(prefix_options, query_options)
            instantiate_collection( (format.decode(connection.get(path, request_headers).body) || []), query_options, prefix_options )
          end
        rescue ActiveResource::ResourceNotFound
          # Swallowing ResourceNotFound exceptions and return [] - as per
          # ActiveRecord.
          []
        end
      end

      def find_one(options, api_key)
        request_headers = authorize_headers(api_key)
        case from = options[:from]
        when Symbol
          instantiate_record(get(from, options[:params]))
        when String
          path = "#{from}#{query_string(options[:params])}"
          instantiate_record(format.decode(connection.get(path, request_headers).body))
        end
      end

      def find_single(scope, options, api_key)
        request_headers = authorize_headers(api_key)
        prefix_options, query_options = split_options(options[:params])
        path = element_path(scope, prefix_options, query_options)
        instantiate_record(format.decode(connection.get(path, request_headers).body), prefix_options)
      end

      protected

      def authorize_headers(api_key)
        new_headers = headers.dup
        new_headers['X-Api-Key'] = api_key
        new_headers
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

require 'new_relic_api/application'
require 'new_relic_api/application_host'
require 'new_relic_api/application_instance'
require 'new_relic_api/server'
require 'new_relic_api/user'
