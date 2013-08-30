# Arel based search
#
# Basic usage:
#
# params = {'orders.status.eq' => 50}
# ArelSearch::Base.new(Order, params).search
#
#
# Query by association
# params = {'orders.status.eq' => 50, 'customer.name.matches' => 'Marcus'}
# 
# Paginate (3rd party)
# ArelSearch::Base.new(Order, params).search.paginate(page: 1, per_page: 10)
module ArelSearch
  class Base
    attr_reader :fields, :model, :params
    attr_accessor :scope

    def initialize(m, params={})
      @model  = m
      @scope  = self.model
      @params = params
    end

    def search
      scope_conditions
      self.scope
    end

    private

    def scope_conditions
      build_search_fields.each do |field|
        self.scope = field.scopify(self.scope, self.model.arel_table)
      end
    end

    def build_search_fields
      self.params.inject([]){|fields, param| fields << search_field(param)}
    end

    def search_field(param)
       SearchField.new(param[0], param[1], self.model)
    end

    class SearchField

      NAMESPACE_SYMBOL = '::'

      attr_reader :name, :value, :association, :namespace, :arel_predication, :split, :base_model

      def initialize(key, v, b_model)
        @base_model              = b_model
        split_key(key)
        @association, @namespace = set_association_and_namespace(self.split[0])
        self.name                = self.split[1]
        self.arel_predication    = self.split[2]
        @value                   = v
      end

      def scopify(scope, default_arel_table)
        if self.arel_table != default_arel_table
          scope = scope.joins(self.association.to_sym)
        end
        scope.where(self.arel_table[self.name].send(self.arel_predication,self.value))
      end

      def name=(n)
        validate_name(n)
        @name = n
      end

      def arel_predication=(pred)
        validate_arel_predication(pred)
        @arel_predication = pred
      end

      def arel_table
        self.model.arel_table
      end

      def model
        "#{namespace}#{NAMESPACE_SYMBOL}#{association.camelize.singularize}".constantize
      end

      private

      def split_key(key)
        @split = key.split('.')
      end

      def validate_name(name)
        set_model_columns
        if !@@columns[self.model.name].include?(name)
          raise NoMethodError, "Column #{name} not found for Table #{self.model.table_name}"
        end
      end

      def set_model_columns
        @@columns ||= {}
        @@columns[self.model.name] ||= self.model.columns.inject({}){|h,c| h[c.name] = c.type.to_s; h}
      end

      def validate_arel_predication(predication)
        set_arel_predications
        if !@@arel_predications.include?(predication)
          raise NoMethodError, "Predication #{predication} not found for Module Arel::Predications"
        end
      end

      def set_arel_predications
        @@arel_predications ||= Arel::Predications.instance_methods.map(&:to_s)
      end

      def set_association_and_namespace(association_namespaced)
        split = association_namespaced.split(NAMESPACE_SYMBOL)
        if split.size > 1
          namespace   = split[0]
          association = split[1]
        else
          namespace   = ''
          association = association_namespaced
        end
        return association, namespace
      end

    end

  end
end