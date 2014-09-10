class NewRelicApi::ApplicationCollection < ActiveResource::Collection
  def initialize(parsed={})
    @elements = parsed['applications']
  end
end

class NewRelicApi::Application < NewRelicApi::BaseResource
  has_many :application_hosts
  has_many :application_instances

  self.collection_parser = ::NewRelicApi::ApplicationCollection

  def query_params
    {:application_id => id}
  end
end
