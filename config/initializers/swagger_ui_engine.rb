
SwaggerUiEngine.configure do |config|
  config.swagger_url = {
      v1: '/api/v1/swagger_doc.json',
  }

  config.doc_expansion = 'full'
  config.model_rendering = 'model'
  config.validator_enabled = true
end
