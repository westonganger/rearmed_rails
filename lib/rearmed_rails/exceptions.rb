module RearmedRails
  module Exceptions

    class PatchesAlreadyAppliedError < StandardError
      def initialize
        super("Cannot change or apply patches again after `RearmedRails#apply_patches!` has been called.")
      end
    end

  end
end
