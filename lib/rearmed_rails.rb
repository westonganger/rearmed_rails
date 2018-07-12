require 'rearmed_rails/version'

module RearmedRails

  DEFAULT_PATCHES = eval(File.read(File.join(File.dirname(__FILE__), 'rearmed_rails/default_enabled_patches.hash'))).freeze
  private_constant :DEFAULT_PATCHES
  
  @enabled_patches = Marshal.load(Marshal.dump(DEFAULT_PATCHES)) 
  @applied = false

  def self.enabled_patches=(val)
    if @applied
      raise ::RearmedRails::Exceptions::PatchesAlreadyAppliedError.new
    else
      if val.nil?
        @enabled_patches = Marshal.load(Marshal.dump(DEFAULT_PATCHES)) 
      elsif val == :all
        @enabled_patches = val
      elsif val.is_a?(Hash)
        @enabled_patches = Marshal.load(Marshal.dump(DEFAULT_PATCHES)) 

        DEFAULT_PATCHES.keys.each do |k|
          methods = val[k] || val[k.to_sym]
          if methods
            if methods.is_a?(Hash) || methods == true
              @enabled_patches[k] = methods
            else
              raise TypeError.new('Invalid value within the hash passed to Rearmed.enabled_patches=')
            end
          end
        end
      else
        raise TypeError.new('Invalid value passed to Rearmed.enabled_patches=')
      end
    end
  end

  def self.enabled_patches
    @enabled_patches
  end

  def self.apply_patches!
    if @applied 
      raise ::RearmedRails::Exceptions::PatchesAlreadyAppliedError.new
    else
      patches_folder = File.expand_path('../rearmed_rails/monkey_patches', __FILE__)
      Dir[File.join(patches_folder, '**/*.rb')].each do |filename| 
        require filename
      end

      @applied = true 
    end
  end

  private

  def self._dig(collection, *values)
    current_val = nil
    current_collection = collection
    values.each_with_index do |val,i|
      if i+1 == values.length
        if (current_collection.is_a?(Array) && val.is_a?(Integer)) || (current_collection.is_a?(Hash) && ['String','Symbol'].include?(val.class.name))
          current_val = current_collection[val]
        else
          current_val = nil
        end
      elsif current_collection.is_a?(Array)
        if val.is_a?(Integer)
          current_collection = current_collection[val]
          next
        else
          current_val = nil
          break
        end
      elsif current_collection.is_a?(Hash)
        if ['Symbol','String'].include?(val.class.name)
          current_collection = current_collection[val]
          next
        else
          current_val = nil
          break
        end
      else
        current_val = nil
        break 
      end
    end

    return current_val
  end

end
