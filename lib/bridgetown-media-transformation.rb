# frozen_string_literal: true

require "bridgetown"
require "bridgetown-media-transformation/media_transformation"
require "bridgetown-media-transformation/builder"

module BridgetownMediaTransformation
end

Bridgetown.initializer :"bridgetown-media-transformation" do |config|
  config.bridgetown_media_transformation ||= {}
  config.builder BridgetownMediaTransformation::Builder
end
