require_relative "../config/environment.rb"
require 'pry'
class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(name, grade, id = nil)
    @name, @grade, @id = name, grade, id
  end

  attr_accessor :id, :name, :grade

  def self.create_table
    sql = <<-SQL
      CREATE TABLE students (ID INTEGER PRIMARY KEY, NAME TEXT, GRADE INTEGER);
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students;
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade) VALUES (? , ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      sql_id = <<-SQL
        SELECT last_insert_rowid() FROM students
      SQL
      @id = DB[:conn].execute(sql_id).flatten[0]
    end
  end

  def self.create(name, grade)
    Student.new(name, grade).save
  end

  def self.new_from_db(db_row)
    Student.new(db_row[1], db_row[2], db_row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students WHERE name = ?
    SQL
    row = DB[:conn].execute(sql, name).flatten
    Student.new(row[1], row[2], row[0])
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, name,  grade,  id)
  end

end
