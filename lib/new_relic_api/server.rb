class NewRelicApi::ServerCollection < ActiveResource::Collection
  attr_accessor :links
  def initialize(parsed={})
    @elements = parsed['servers']
    @links = parsed['links']
  end
end

class NewRelicApi::Server < NewRelicApi::BaseResource
  self.collection_parser = NewRelicApi::ServerCollection
end
