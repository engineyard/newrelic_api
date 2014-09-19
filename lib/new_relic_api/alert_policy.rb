class NewRelicApi::AlertPolicyCollection < ActiveResource::Collection
  def initialize(parsed={})
    @elements = parsed['alert_policies']
    @links = parsed['links']
  end
end

class NewRelicApi::AlertPolicy < NewRelicApi::BaseResource
  self.collection_parser = ::NewRelicApi::AlertPolicyCollection
  self.format = NewRelicApi::JsonApiFormatter.new("alert_policy")
end
