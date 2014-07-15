class NewRelicApi::ApplicationInstance < NewRelicApi::BaseResource
  self.prefix = "/v2/applications/:application_id/"
  self.format = NewRelicApi::JsonApiFormatter.new("application_instances")
  self.element_name = "instance"
end
