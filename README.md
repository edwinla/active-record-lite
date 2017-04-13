# ActiveRecord Lite

## Description


ActiveRecord Lite is a lightweight version of the Ruby on Rails gem built using metaprogramming techniques. Built from the ground up, ActiveRecord Lite includes key functionality from the original gem to describe object-relationships in a database. Functionalities include:

- SQL objects
- Searchable
- Object relationships

## Implementation

#### SQL Objects

The SQL objects implemented in ActiveRecord Lite mimics many of the methods included with all `ActiveModel` classes. They include:
- `::all` - returns all instances of SQL object class
- `::find`(id) - returns instance of SQL object class with provided id
- `::columns` - returns SQL object class's columns
- `::table_name` - returns SQL object class's table name
- `::table_name=(table_name)` - renames SQL object's table name
- `#save` - saves SQL object to database
- `#attributes` - lists SQL object's attributes
- `#attribute_values` - lists SQL object's attribute values
- `#update` - Updates SQL object's attributes

To interact with the database, a I created a `DBConnection::` (`lib/db_connection.rb`) class as middleware. For example, `::find`:
```
def self.find(id)
  result = DBConnection.execute(<<-SQL, id).first
    SELECT
      *
    FROM
      #{self.table_name}
    WHERE
      id = ?
  SQL

  result ? self.new(result) : nil
end
```

#### Searchables
The "Searchable" module enables `::where` queries across SQL objects using key-value relationships of a typical Ruby hash. An example use case is filtering:
```
pry(main)> Cat.where({name: 'Markov'})
pry(main)> #<Cat:0x007fa409cee528 @attributes={:id=>3, :name=>"Markov", :temperament=>"happy"}>
```

#### Object Relationships
One of ActiveRecord's main features include finding associated data relationships via foreign keys. Through the `Associatable` module, column-column relationships can be found between two SQL tables. For example, the `#has_many` method is defined as below:
```
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
```
