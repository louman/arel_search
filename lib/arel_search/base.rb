# Arel based search
#
# Basic usage:
#
# params = {'orders.status.eq' => 50}
# ArelSearch::Base.new(Order, params).search_all
#
#
# Query by association
# params = {'orders.status.eq' => 50, 'customer.name.matches' => 'Marcus'}
# 
# Paginate
# ArelSearch::Base.new(Order, params).search(page: 1, per_page: 10)
#
# TODO:
# 
# Implement NoMethodError for columns and Arel predications
module ArelSearch
  class Base
    attr_reader :fields, :model, :params
    attr_accessor :scope

    def initialize(m, params)
      @model  = m
      @scope  = self.model
      @params = params
    end

    def search_all
      scope_conditions
      self.scope
    end

    def search(page=1, per_page=20)
      self.search_all.paginate(per_page: per_page, page: page)
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
      attr_reader :name, :value, :association, :arel_predication, :split, :base_model

      def initialize(key, v, b_model)
        @base_model       = b_model
        split_key(key)
        @association          = self.split[0]
        self.name             = self.split[1]
        self.arel_predication = self.split[2]
        @value                = v
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
        self.association.camelize.singularize.constantize
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

    end

  end
end