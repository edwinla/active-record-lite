require_relative '02_searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    default_options = {
      primary_key: :id,
      foreign_key: "#{name}_id".to_sym,
      class_name: name.to_s.camelcase
    }.merge(options)
    default_options.each { |key, value| self.send("#{key}=", value) }
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    default_options = {
      primary_key: :id,
      foreign_key: "#{self_class_name.underscore}_id".to_sym,
      class_name: name.to_s.singularize.camelcase
    }.merge(options)

    default_options.each { |key, value| self.send("#{key}=", value) }
  end
end

module Associatable
  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)
    define_method(name) do
      options = self.class.assoc_options[name]
      foreign_key_value = self.send(options.foreign_key)
      options
        .model_class
        .where(options.primary_key => foreign_key_value)
        .first
    end
  end

  def has_many(name, options = {})
    self.assoc_options[name] = HasManyOptions.new(name, self.name, options)
    define_method(name) do
      options = self.class.assoc_options[name]
      primary_key_value = self.send(options.primary_key)
      options
        .model_class
        .where(options.foreign_key => primary_key_value)
    end
  end

  def assoc_options
    @assoc_options ||= {}
    @assoc_options
  end
end

class SQLObject
  extend Associatable
end
