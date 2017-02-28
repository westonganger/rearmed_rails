require 'rails/generators'

module RearmedRails
  class SetupGenerator < Rails::Generators::Base

    def setup
      create_file "config/initializers/rearmed_rails.rb", <<eos
RearmedRails.enabled_patches = #{File.read(File.join(File.dirname(__FILE__), '../../rearmed_rails/default_enabled_patches.hash'))}

require 'rearmed_rails/apply_patches'
eos
    end

  end
end
