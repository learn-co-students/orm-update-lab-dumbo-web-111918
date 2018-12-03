require_relative "../config/environment.rb"

class Student

	attr_accessor :name, :grade
	attr_reader :id

	def initialize(name, grade, id=nil)
		@id = id
		@name = name
		@grade = grade
	end

	def self.create_table
		sql = <<-SQL
      CREATE TABLE students(
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
      );
    SQL

    DB[:conn].execute(sql)
	end

	def self.drop_table
		sql = <<-SQL
      		DROP TABLE students
    	SQL

    DB[:conn].execute(sql)
	end

	def save

	if @id
    	update
	else
	    sql = <<-SQL
	      INSERT INTO students (name, grade)
	      VALUES (?, ?)
	    SQL
	    DB[:conn].execute(sql, self.name, self.grade)
	    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
	end
  end

	def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end

	def self.new_from_db(row)
    # create a new Student object given a row from the database
    Student.new(row[1], row[2], row[0])
  end

	def self.find_by_name(name)
    # find the student in the database given a name
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = "#{name}"
    SQL

    DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
    end.first
    # return a new instance of the Student class
  end

	def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, @name, @grade, @id)
    row = DB[:conn].execute("SELECT * FROM students WHERE id = ?", @id)[0]
    @name = row[1]
    @grade = row[2]
  end
end
