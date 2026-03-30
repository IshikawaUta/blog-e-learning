require_relative '../lib/database'

class Post
  attr_accessor :id, :title, :content, :thumbnail_url, :thumbnail_public_id, :author_id, :category_id, :created_at, :updated_at

  def initialize(attributes = {})
    @id = attributes['id']
    @title = attributes['title']
    @content = attributes['content']
    @thumbnail_url = attributes['thumbnail_url']
    @thumbnail_public_id = attributes['thumbnail_public_id']
    @author_id = attributes['author_id']
    @category_id = attributes['category_id']
    @created_at = attributes['created_at']
    @updated_at = attributes['updated_at']
  end

  def self.all
    results = Database.query("SELECT * FROM posts ORDER BY created_at DESC")
    results.map { |row| new(row) }
  end

  def self.count(search: nil, category_id: nil)
    sql = "SELECT COUNT(*) as total FROM posts WHERE 1=1"
    params = []
    
    if search && !search.empty?
      sql += " AND MATCH(title, content) AGAINST(? IN NATURAL LANGUAGE MODE)"
      params << search
    end
    
    if category_id && !category_id.to_s.empty?
      sql += " AND category_id = ?"
      params << category_id.to_i
    end
    
    results = Database.query(sql, *params)
    results.first['total']
  end

  def self.paginate(page: 1, per_page: 6, search: nil, category_id: nil)
    page_num = [page.to_i, 1].max
    offset = (page_num - 1) * per_page.to_i
    
    sql = "SELECT p.*, c.name as category_name FROM posts p LEFT JOIN categories c ON p.category_id = c.id WHERE 1=1"
    params = []
    
    if search && !search.empty?
      sql += " AND MATCH(p.title, p.content) AGAINST(? IN NATURAL LANGUAGE MODE)"
      params << search
    end
    
    if category_id && !category_id.to_s.empty?
      sql += " AND p.category_id = ?"
      params << category_id.to_i
    end
    
    sql += " ORDER BY p.created_at DESC LIMIT ? OFFSET ?"
    params << per_page.to_i << offset
    
    results = Database.query(sql, *params)
    results.map do |row| 
      post = new(row)
      post.instance_variable_set(:@category_name, row['category_name'])
      post.define_singleton_method(:category_name) { @category_name }
      post
    end
  end

  def self.find(id)
    results = Database.query("SELECT * FROM posts WHERE id = ?", id)
    row = results.first
    row ? new(row) : nil
  end

  def save
    if @id
      Database.query("UPDATE posts SET title = ?, content = ?, thumbnail_url = ?, thumbnail_public_id = ?, category_id = ? WHERE id = ?", @title, @content, @thumbnail_url, @thumbnail_public_id, @category_id, @id)
    else
      Database.query("INSERT INTO posts (title, content, thumbnail_url, thumbnail_public_id, author_id, category_id) VALUES (?, ?, ?, ?, ?, ?)", @title, @content, @thumbnail_url, @thumbnail_public_id, @author_id, @category_id)
      @id = Database.last_id
    end
    self
  end

  def destroy
    Database.query("DELETE FROM posts WHERE id = ?", @id)
  end
end
