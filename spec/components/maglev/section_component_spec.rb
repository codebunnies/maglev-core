# frozen_string_literal: true

require 'rails_helper'

describe Maglev::SectionComponent do
  let(:theme) { build(:theme) }
  let(:page) { build(:page, :with_navbar).tap { |page| page.prepare_sections(theme) } }
  let(:config) { instance_double('MaglevConfig', asset_host: 'https://assets.maglev.local') }
  let(:page_component) { instance_double('PageCommponent', page: page, config: config) }
  let(:attributes) { page.sections[1].deep_symbolize_keys }
  let(:definition) { build(:section, category: 'headers') }
  let(:view_context) { FooController.new.view_context }
  let(:templates_root_path) { 'theme' }
  let(:component) do
    described_class.new(
      parent: page_component,
      attributes: attributes,
      definition: definition,
      templates_root_path: templates_root_path
    ).tap { |c| c.view_context = view_context }
  end

  describe '#dom_data' do
    subject { component.dom_data }

    it 'returns a HTML formatted data attribute' do
      expect(subject).to eq 'data-maglev-section-id="def"'
    end
  end

  describe '#render' do
    subject { pretty_html(component.render) }

    context 'using low-level tags (ex: jumbotron)' do
      it 'returns a valid HTML' do
        expect(subject).to eq(<<~HTML
          <div data-maglev-section-id="def" class="jumbotron">
            <div class="container">
              <h1 data-maglev-id="def.title" class="display-3">Hello world</h1>
              <div data-maglev-id="def.body">
                <p>Lorem ipsum</p>
              </div>
            </div>
          </div>
        HTML
        .strip)
      end
    end

    context 'using the fancy Maglev tags (ex: navbar)' do
      let(:attributes) { page.sections[0].deep_symbolize_keys }
      let(:definition) { build(:section, :navbar) }

      it 'returns a valid HTML' do
        expect(subject).to eq(<<~HTML
          <div class="navbar" id="section-abc" data-maglev-section-id="abc">
            <a href="/">
              <img src="logo.png" data-maglev-id="abc.logo" class="brand-logo"/>
            </a>
            <nav>
              <ul>
                <li class="navbar-item" id="block-menu-item-0" data-maglev-block-id="menu-item-0">
                  <a data-maglev-id="menu-item-0.link" href="/">
                    <em>
                      <span data-maglev-id="menu-item-0.label">Home</span>
                    </em>
                  </a>
                </li>
                <li class="navbar-item" id="block-menu-item-1" data-maglev-block-id="menu-item-1">
                  <a data-maglev-id="menu-item-1.link" href="/about-us">
                    <em>
                      <span data-maglev-id="menu-item-1.label">About us</span>
                    </em>
                  </a>
                  <ul>
                    <li class="navbar-nested-item" id="block-menu-item-1-1" data-maglev-block-id="menu-item-1-1">
                      <a data-maglev-id="menu-item-1-1.link" class="navbar-link" href="/about-us/team">
                        <span data-maglev-id="menu-item-1-1.label">Our team</span>
                      </a>
                    </li>
                    <li class="navbar-nested-item" id="block-menu-item-1-2" data-maglev-block-id="menu-item-1-2">
                      <a data-maglev-id="menu-item-1-2.link" target="_blank" class="navbar-link" href="/about-us/office">
                        <span data-maglev-id="menu-item-1-2.label">Our office</span>
                      </a>
                    </li>
                  </ul>
                </li>
              </ul>
            </nav>
          </div>
        HTML
        .strip)
      end
    end
  end
end

class FooController < ::ApplicationController
  include Maglev::StandaloneSectionsConcern

  private

  def maglev_site_root_fullpath
    '/'
  end
end
