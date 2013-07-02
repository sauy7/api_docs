class ApiDocs::Configuration
  
  # Where to find the folder with documentation files
  attr_accessor :docs_path
  
  # Array of ignored attributes. Attributes that don't really change
  # the content like timestamps.
  attr_accessor :ignored_attributes
  
  # Remove doc files before running tests. False by default.
  attr_accessor :reload_docs_folder
  
  # Generates docs on demand only. False by default
  # When enabled docs will generate only if `ENV['API_DOCS']` is set
  attr_accessor :generate_on_demand
  
  # Remove attributes which shouldn't be calculated in the key hash.
  # Is useful when you're using auto generated tokens.
  attr_accessor :exclude_key_params
    
  # Configuration defaults
  def initialize
    @docs_path          = Rails.root.join('doc/api')
    @ignored_attributes = %w(created_at updated_at)
    @reload_docs_folder = false
    @generate_on_demand = false
    @exclude_key_params = []
  end
end