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

  if enabled || RearmedRails.dig(RearmedRails.enabled_patches, :rails, :helpers, :field_is_array)
    module ActionView 
      module Helpers
        module Tags
          class Base
            private

            original_method = instance_method(:add_default_name_and_id)
            define_method :add_default_name_and_id  do |options|
              original_method.bind(self).(options)

              if options['is_array'] && options['name']
                options['name'] = "#{options['name']}[]"
              end
            end
          end
        end
      end
    end
  end

  module RearmedRails
    module RailsHelpers
    end
  end

  RearmedRails::RailsHelpers.module_eval do

    if enabled || RearmedRails.dig(RearmedRails.enabled_patches, :rails, :helpers, :options_for_select_include_blank)
      def options_for_select(container, selected = nil)
        if selected.is_a?(Hash)
          include_blank = selected[:include_blank] || selected['include_blank']
        end

        options = super

        if include_blank
          include_blank = '' if include_blank == true

          if Rails::VERSION::MAJOR >= 5 && Rails::VERSION::MINOR >= 1
            str = tag_builder.content_tag_string(:option, include_blank, {value: ''})
          else
            str = content_tag_string(:option, include_blank, {value: ''})
          end

          options.prepend(str)
        end

        options
      end
    end

    if enabled || RearmedRails.dig(RearmedRails.enabled_patches, :rails, :helpers, :options_for_select_include_blank)
      def options_from_collection_for_select(collection, value_method, text_method, selected = nil)
        options = collection.map do |element|
          [value_for_collection(element, text_method), value_for_collection(element, value_method), option_html_attributes(element)]
        end

        options_for_select(options, selected)
      end
    end
  end

  ActiveSupport.on_load :action_view do
    ActionView::Base.send(:include, RearmedRails::RailsHelpers)
  end
end
