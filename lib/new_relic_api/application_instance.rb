class NewRelicApi::ApplicationInstanceCollection < ActiveResource::Collection
  def initialize(parsed={})
    @elements = parsed['instances']
  end
end

class NewRelicApi::ApplicationInstance < NewRelicApi::BaseResource
  self.prefix = "/v2/applications/:application_id/"
end
