class NewRelicApi::UserCollection < ActiveResource::Collection
  def initialize(parsed={})
    @elements = parsed['users']
  end
end

class NewRelicApi::User < NewRelicApi::BaseResource
  self.collection_parser = NewRelicApi::UserCollection
  self.format = NewRelicApi::JsonApiFormatter.new('user')
end
