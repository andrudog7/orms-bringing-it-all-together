class Dog
    attr_accessor :name, :breed, :id
    

    def initialize(hash)
        @id = hash[:id]
        @name = hash[:name] 
        @breed = hash[:breed] 
    end

    def self.create_table
        sql =  <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
    end

    def save 
        sql =  <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").flatten.first
        self
    end

    def self.create(hash)
        dog = Dog.new(hash)
        dog.save 
        dog
    end

    def self.new_from_db(array)
        self.new({id: array[0], name: array[1], breed: array[2]})
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * FROM dogs GROUP BY id HAVING id = ?
        SQL
        dog_array = DB[:conn].execute(sql, id)
        self.new_from_db(dog_array.flatten)
    end

    def self.find_or_create_by(hash)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1", hash[:name], hash[:breed])
        if !dog.empty?
            dog_data = dog[0]
            dog = Dog.new_from_db(dog_data)
        else 
            dog = Dog.create(hash)
        end
    end

    def self.find_by_name(name)
        self.new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).flatten)
    end 

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end