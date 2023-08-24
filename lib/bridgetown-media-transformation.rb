# frozen_string_literal: true

require "bridgetown"
require "bridgetown-media-transformation/media_transformation"
require "bridgetown-media-transformation/builder"

Bridgetown.initializer :bridgetown_media_transformation do |config, api_key: ''|
  config.bridgetown_media_transformation ||= {}
  config.builder BridgetownMediaTransformation::Builder
end
