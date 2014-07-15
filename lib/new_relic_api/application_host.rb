class NewRelicApi::ApplicationHost < NewRelicApi::BaseResource
  self.prefix = "/v2/applications/:application_id/"
  self.format = NewRelicApi::JsonApiFormatter.new("application_hosts")
  self.element_name = "host"
end
