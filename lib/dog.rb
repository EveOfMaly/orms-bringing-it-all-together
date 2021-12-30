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
        DB[:conn].execute("SELECT * from dogs where id = ? Limit 1  ", id_num).map do |row|
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
        #if dog exist point to the existing dog instance,
        else
            dog = self.create(attr)
        #else crete a new dog
        end
    end

    def self.find_by_name(name)

        DB[:conn].execute("SELECT * from dogs where name = ? Limit 1 ", name).map do |row|
            self.new_from_db(row)
        end.first

    end



    def update 
        DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?",self.name, self.breed, self.id)
    end





    
end




