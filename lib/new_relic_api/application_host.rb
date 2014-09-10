class NewRelicApi::ApplicationHostCollection < ActiveResource::Collection
  def initialize(parsed={})
    @elements = parsed['hosts']
  end
end

class NewRelicApi::ApplicationHost < NewRelicApi::BaseResource
  self.prefix = "/v2/applications/:application_id/"
  self.collection_parser = NewRelicApi::ApplicationHostCollection
  self.format = NewRelicApi::JsonApiFormatter.new('host')
end
