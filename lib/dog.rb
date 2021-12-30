require 'pry'

class Dog

    attr_accessor :name, :breed, :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table 
        DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
    end

    def self.drop_table 
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end

    def save 

        if self.id
            self.update 
        else
            DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() from dogs")[0][0]
            self
        end
    end

    def self.create(attr)
        dog = Dog.new(attr)
        dog.save 
        dog
    end

    def self.new_from_db(row)
        dog = Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id_num)
        DB[:conn].execute("SELECT * from dogs where id = ? ", id_num).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(attr)
        name = attr[:name]
        breed = attr[:breed]
        #query database for the object 
        dog = DB[:conn].execute("SELECT * from dogs where name = ? AND breed = ?", name, breed)
        if !dog.empty?
            dog_data = dog[0]
            dog = self.new_from_db(dog_data)
            # dog = Dog.new(id: dog_data[0],name: dog_data[1], breed: dog_data[2])
        #if dog exist point to the existing dog instance,
        else
            dog = self.create(attr)
        #else crete a new dog
        end
    end

    def self.find_by_name(name)

        DB[:conn].execute("SELECT * from dogs where name = ? ", name).map do |row|
            self.new_from_db(row)
        end.first

    end



    def update 
        DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?",self.name, self.breed, self.id)
    end





    
end
























# attr_accessor :name, :breed
    # attr_reader :id

    # def initialize(attribute)
    #     @id = attribute[:id]
    #     @name = attribute[:name]
    #     @breed = attribute[:breed]
    # end

    # def self.create_table
    #     DB[:conn].execute( "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
    # end

    # def self.drop_table
    #     DB[:conn].execute( "DROP TABLE IF EXISTS dogs")
    # end

    # def save
    #     if self.id
    #         self.update
    #     else
    #         DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
    #         @id =  DB[:conn].execute("SELECT last_insert_rowid() from dogs")[0][0]
    #     end
    #     self
    # end

    # def self.create(attributes)
    #     new_dog = Dog.new(attributes)
    #     new_dog.save 
    #     new_dog
    # end

    # def self.new_from_db(row)
    #     dog_id = row[0]
    #     dog_name = row[1]
    #     dog_breed = row[2]

    #     attributes = {id: dog_id, name: dog_name, breed: dog_breed}

    #     self.new(attributes)
    # end

    # def self.find_by_name(name_in_database)
    #     row = DB[:conn].execute( "SELECT * FROM dogs WHERE name = ? LIMIT 1", name_in_database)
    #     self.new_from_db(row)
    #     self.name
    # end

    # def self.find_by_id(id_num)
    #     dog_info = DB[:conn].execute( "SELECT * FROM dogs WHERE id = ? LIMIT 1", id_num).flatten
    #     self.new_from_db(db_info)
    #     self.id
    # end


    # def update
    #     sql = "UPDATE dogs SET name = ?, breed = ? where id = ?"
    #     DB[:conn].execute(sql, self.name, self.breed, self.id)
    # end
