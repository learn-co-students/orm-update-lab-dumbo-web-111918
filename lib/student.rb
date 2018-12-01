require 'pry'

require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade, :id
  # DB[:conn]
  def initialize(name, grade)
    @name = name
    @grade = grade
    @id = nil
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students;
    SQL
    DB[:conn].execute(sql)
  end

  def self.create(name, grade)
    new_stu = Student.new(name, grade)
    new_stu.save
    new_stu
  end

  def self.new_from_db(row)
    new_stu = Student.new(row[1], row[2])
    new_stu.id = row[0]
    new_stu
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students
      WHERE name = ?;
    SQL
    new_stu = DB[:conn].execute(sql, name).first
    self.new_from_db(new_stu)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?);
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?;
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
end
