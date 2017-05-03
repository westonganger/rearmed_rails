enabled = RearmedRails.enabled_patches[:rails] == true
enabled ||= RearmedRails.dig(RearmedRails.enabled_patches, :rails, :active_record) == true

if defined?(ActiveRecord)

  if enabled || RearmedRails.dig(RearmedRails.enabled_patches, :rails, :active_record, :or)

    if Rails::VERSION::MAJOR > 4

      unless defined?(ActiveRecord::Relation::QueryMethods)
        module ActiveRecord
          class Relation
            module QueryMethods
            end
          end
        end
      end

      module RearmedRails
        class OrChain
          def initialize(scope)
            @scope = scope
          end

          def method_missing(method, *args, &block)
            other = @scope.klass.unscoped do
              @scope.klass.send(method, *args, &block)
            end
            return @scope.or(other)
          end
        end
      end

      ActiveRecord::QueryMethods.module_eval do
        def or(opts=nil, *rest)
          if opts.nil?
            return RearmedRails::OrChain.new(self)
          else
            other = opts.is_a?(ActiveRecord::Relation) ? opts : klass.unscoped.where(opts, rest)

            self.where_clause = self.where_clause.or(other.where_clause)
            self.having_clause = self.having_clause.or(other.having_clause)

            return self
          end
        end
      end

    else # end of Rails 5+ section, Rails 4 below

      module ActiveRecord
        module Querying
          delegate :or, to: :all
        end

        module QueryMethods
          class OrChain
            def initialize(scope)
              @scope = scope
            end

            def method_missing(method, *args, &block)
              right_relation = @scope.klass.unscoped do
                @scope.klass.send(method, *args, &block)
              end
              @scope.or(right_relation)
            end
          end

          def or(opts = :chain, *rest)
            if opts == :chain
              OrChain.new(self)
            else
              left = self
              right = (ActiveRecord::Relation === opts) ? opts : klass.unscoped.where(opts, rest)

              unless left.where_values.empty? || right.where_values.empty?
                left.where_values = [left.where_ast.or(right.where_ast)]
                right.where_values = []
              end

              left = left.merge(right)
            end
          end

          private # Returns an Arel AST containing only where_values

          def where_ast
            arel_wheres = []

            where_values.each do |where|
              arel_wheres << (String === where ? Arel.sql(where) : where)
            end

            return Arel::Nodes::Grouping.new(Arel::Nodes::And.new(arel_wheres)) if arel_wheres.length >= 2

            if Arel::Nodes::SqlLiteral === arel_wheres.first
              Arel::Nodes::Grouping.new(arel_wheres.first)
            else
              arel_wheres.first
            end
          end
        end
      end

    end # end of Rails 4 section

  end

end
