module Releaf::Builders::View
  include Releaf::Builders::Base
  include Releaf::Builders::Template

  def output
    safe_join do
      [header, section]
    end
  end

  def header
    tag(:header) do
      [breadcrumbs, flash_notices, header_extras]
    end
  end

  def section
    tag(:section) do
      section_blocks
    end
  end

  def breadcrumbs
    breadcrumb_items = template.instance_variable_get("@breadcrumbs")
    return nil unless breadcrumb_items.present?

    tag(:nav) do
      tag(:ul, class: "block breadcrumbs") do
        safe_join do
          last_item = breadcrumb_items.last
          breadcrumb_items.each.collect do |item, index|
            breadcrumb_item(item, item == last_item)
          end
        end
      end
    end
  end

  def breadcrumb_item(item, last)
    tag(:li) do
      if item[:url].present?
        tag(:a, href: item[:url]) do
          item[:name]
        end
      else
        item[:name]
      end << ( template.fa_icon("small chevron-right") unless last)
    end
  end

  def flash_notices
    safe_join do
      template.flash.collect do |name, item|
        flash(name, item)
      end
    end
  end

  def flash(name, item)
    tag(:div, class: "flash", 'data-type' => name, :'data-id' => (item.is_a? (Hash)) && (item.has_key? "id") ? item["id"] : nil) do
      item.is_a?(Hash) ? item["message"] : item
    end
  end

  def header_extras
  end



  def section_blocks
    [section_header, section_body, section_footer]
  end

  def section_header
    tag(:header) do
      [tag(:h1, section_header_text), section_header_extras]
    end
  end

  def section_body
  end

  def section_footer
    tag(:footer) do
      footer_tools
    end
  end

  def footer_tools
    tag(:div, class: "tools") do
      tag(:div, class: "primary") do
        footer_primary_tools
      end <<
      tag(:div, class: "secondary") do
        footer_secondary_tools
      end
    end
  end

  def footer_primary_tools
  end

  def footer_secondary_tools
  end


end
