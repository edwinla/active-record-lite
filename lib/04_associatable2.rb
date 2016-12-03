require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)


    define_method(name) do

      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      tt = through_options.table_name
      st = source_options.table_name
      t_pk = through_options.primary_key
      s_pk = source_options.primary_key
      t_fk = through_options.foreign_key
      s_fk = source_options.foreign_key
      t_fk_val = self.send(t_fk)

      results = DBConnection.execute(<<-SQL, t_fk_val)
        SELECT
          #{st}.*
        FROM
          #{tt}
        JOIN
          "#{st}"
        ON
          #{tt}.#{s_fk} = #{st}.#{s_pk}
        WHERE
          #{tt}.#{t_pk} = ?
      SQL

      source_options.model_class.parse_all(results).first
    end
  end
end
