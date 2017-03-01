if defined?(Minitest::Assertions)

  enabled = RearmedRails.enabled_patches[:minitest] == true

  Minitest::Assertions.module_eval do

    if enabled || RearmedRails.dig(RearmedRails.enabled_patches, :minitest, :assert_changed)
      def assert_changed(expression, &block)
        if expression.respond_to?(:call)
          e = expression
        else
          e = lambda{ block.binding.eval(expression) }
        end
        old = e.call
        block.call
        refute_equal old, e.call
      end
    end

    if enabled || RearmedRails.dig(RearmedRails.enabled_patches, :minitest, :assert_not_changed)
      def assert_not_changed(expression, &block)
        if expression.respond_to?(:call)
          e = expression
        else
          e = lambda{ block.binding.eval(expression) }
        end
        old = e.call
        block.call
        assert_equal old, e.call
      end
    end

  end

end
