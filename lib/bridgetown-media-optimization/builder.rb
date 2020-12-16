# frozen_string_literal: true

require "pry"
require "image_processing/mini_magick"
require "image_processing/vips"

module BridgetownMediaOptimization
  class Builder < Bridgetown::Builder
    def build
      liquid_tag "resp_picture", as_block: true do |attributes, tag|
        path = tag.context["src"]
        path ||= attributes.split(",").map(&:strip).first
        path ||= ""
        # transformation_specs = JSON.parse(attributes.split(",").map(&:strip).last)
        transformation_specs ||= {
          # scaled width, srcset_descriptor
          "webp" => [[640, "640w"], [1024, "1024w"], [1280, "1280w"], [1920, "1920w"], [3840, "2x"]],
          "jpg" => [[640, "640w"], [1024, "1024w"], [1280, "1280w"], [1920, "1920w"], [3840, "2x"]]
        }
        site.data[:media_optimizations] ||= {}
        site.data[:media_optimizations][path] = transformation_specs
        picture_tag(path: path, attributes: tag.content, transformation_specs: transformation_specs)
      end

      hook :site, :post_write do |site|
        # kick off transformations
        site.data[:media_optimizations].each do |path, spec|
          next if path.empty?

          pipeline = ImageProcessing::Vips.source(File.join(site.source, path))

          spec.each do |format, specs|
            pipeline.convert(format) 

            # pipeline.saver(interlace: true) if format == "jpg"

            specs.each do |spec|
              pipeline
                .resize_to_limit(spec.first, spec.first)
                .call(destination: File.join(site.config["destination"], "assets/img/#{file_basename(path)}-#{spec.first}.#{format}"))
            end
          end
        end
      end
    end

    def picture_tag(path:, attributes:, transformation_specs:)
      source_elements = transformation_specs.map do |format, spec|
        srcset = spec.map do |s|
          scaled_width, srcset_descriptor = s
          "#{File.join(File.dirname(path), file_basename(path))}-#{scaled_width}.#{format} #{srcset_descriptor}"
        end.join(", ")
        "<source srcset='#{srcset}' type='image/#{format}'></source>"
      end

      tag = <<~PICTURE
        <picture>
          #{source_elements.join("")}
          <img src="#{path}" #{attributes}>
        </picture>
      PICTURE
      tag
    end

    def file_basename(path)
      File.basename(File.join(site.source, path), ".*")
    end
  end
end

BridgetownMediaOptimization::Builder.register
