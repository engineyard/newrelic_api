class NewRelicApi::AlertPolicyCollection < ActiveResource::Collection
  def initialize(parsed={})

    @elements = parsed['alert_policies']
  end
end

class NewRelicApi::AlertPolicy < NewRelicApi::BaseResource
  self.format = NewRelicApi::JsonApiFormatter.new("alert_policy")
  self.element_name = "alert_policy"

  self.collection_parser = ::NewRelicApi::AlertPolicyCollection

  def query_params
    {}
  end
end
