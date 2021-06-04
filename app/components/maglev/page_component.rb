# frozen_string_literal: true

module Maglev
  class PageComponent < BaseComponent
    attr_reader :site, :theme, :page, :page_sections

    # rubocop:disable Lint/MissingSuper
    def initialize(site:, theme:, page:, page_sections:)
      @site = site
      @theme = theme
      @page = page
      @page_sections = page_sections
    end
    # rubocop:enable Lint/MissingSuper

    # Sections within a dropzone
    def sections
      @sections ||= page_sections.map do |attributes|
        definition = theme.sections.find(attributes['type'])
        next unless definition

        build(
          SectionComponent,
          parent: self,
          definition: definition,
          attributes: attributes.deep_transform_keys! { |k| k.underscore.to_sym },
          templates_root_path: "./#{theme.sections_path}"
        )
      end.compact
    end

    def render
      sections.collect(&:render).join
    end
  end
end