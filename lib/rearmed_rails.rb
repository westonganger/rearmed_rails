require 'rearmed_rails/version'

module RearmedRails

  @enabled_patches = eval(File.read(File.join(File.dirname(__FILE__), 'rearmed_rails/default_enabled_patches.hash')))

  def self.enabled_patches=(val)
    @enabled_patches = val
  end

  def self.enabled_patches
    @enabled_patches
  end

  private

  def self.dig(collection, *values)
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
