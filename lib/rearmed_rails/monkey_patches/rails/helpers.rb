enabled = RearmedRails.enabled_patches[:rails] == true
enabled ||= RearmedRails.dig(RearmedRails.enabled_patches, :rails, :helpers) == true

if defined?(ActionView::Helpers)

  if enabled || RearmedRails.dig(RearmedRails.enabled_patches, :rails, :helpers, :link_to_confirm)
    ActionView::Helpers::UrlHelper.module_eval do
      def convert_options_to_data_attributes(options, html_options)
        if html_options
          html_options = html_options.stringify_keys
          html_options['data-remote'] = 'true' if link_to_remote_options?(options) || link_to_remote_options?(html_options)

          method  = html_options.delete('method')
          add_method_to_attributes!(html_options, method) if method
          
          ### CUSTOM - behave like Rails 3.2
          confirm  = html_options.delete('confirm')
          html_options['data-confirm'] = confirm if confirm

          html_options
        else
          link_to_remote_options?(options) ? {'data-remote' => 'true'} : {}
        end
      end
    end 
  end

  module RearmedRails
    module RailsHelpers
    end
  end

  RearmedRails::RailsHelpers.module_eval do
    if enabled || RearmedRails.dig(RearmedRails.enabled_patches, :helpers, :helpers, :field_is_array)
      original_method = instance_method(:add_default_name_and_id)
      define_method :add_default_name_and_id do |options|
        if options['is_array'] && options['name']
          options['name'] = "#{options['name']}[]"
        end
        original_method.bind(self).(options)
      end
    end

    if enabled || RearmedRails.dig(RearmedRails.enabled_patches, :rails, :helpers, :options_for_select_include_blank)
      def options_for_select(container, selected = nil)
        return container if String === container

        if selected.is_a?(Hash)
          include_blank = selected[:include_blank] || selected['include_blank']
        end

        selected, disabled = extract_selected_and_disabled(selected).map do |r|
          Array(r).map(&:to_s)
        end

        options = []

        if include_blank
          if include_blank == true
            options.push([nil,nil]) 
          else
            options.push([include_blank,include_blank])
          end
        end

        container.each do |element|
          html_attributes = option_html_attributes(element)
          text, value = option_text_and_value(element).map(&:to_s)

          html_attributes[:selected] ||= option_value_selected?(value, selected)
          html_attributes[:disabled] ||= disabled && option_value_selected?(value, disabled)
          html_attributes[:value] = value

          options.push content_tag_string(:option, text, html_attributes)
        end

        options.join("\n").html_safe
      end
    end

    if enabled || RearmedRails.dig(RearmedRails.enabled_patches, :rails, :helpers, :options_from_collection_for_select_include_blank)
      def options_from_collection_for_select(collection, value_method, text_method, selected = nil)
        options = collection.map do |element|
          [value_for_collection(element, text_method), value_for_collection(element, value_method), option_html_attributes(element)]
        end

        if selected.is_a?(Hash)
          include_blank = selected[:include_blank] || selected['include_blank']
        end

        selected, disabled = extract_selected_and_disabled(selected)

        select_deselect = {
          selected: extract_values_from_collection(collection, value_method, selected),
          disabled: extract_values_from_collection(collection, value_method, disabled),
          include_blank: include_blank
        }

        options_for_select(options, select_deselect)
      end
    end
  end

  ActiveSupport.on_load :action_view do
    ActionView::Base.send(:include, RearmedRails::RailsHelpers)
  end
end
