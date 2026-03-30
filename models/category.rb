require_relative '../lib/database'

class Category
  attr_accessor :id, :name, :created_at

  def initialize(attributes = {})
    @id = attributes['id']
    @name = attributes['name']
    @created_at = attributes['created_at']
  end

  def self.all
    results = Database.query("SELECT * FROM categories ORDER BY name ASC")
    results.map { |row| new(row) }
  end

  def self.find(id)
    results = Database.query("SELECT * FROM categories WHERE id = ?", id)
    row = results.first
    row ? new(row) : nil
  end

  def self.find_by_name(name)
    results = Database.query("SELECT * FROM categories WHERE name = ?", name)
    row = results.first
    row ? new(row) : nil
  end

  def save
    if @id
      Database.query("UPDATE categories SET name = ? WHERE id = ?", @name, @id)
    else
      Database.query("INSERT INTO categories (name) VALUES (?)", @name)
      @id = Database.last_id
    end
    self
  end

  def destroy
    Database.query("DELETE FROM categories WHERE id = ?", @id)
  end
end
