require_relative '../lib/database'

class Comment
  attr_accessor :id, :post_id, :name, :content, :is_approved, :created_at

  def initialize(params = {})
    @id = params['id']
    @post_id = params['post_id']
    @name = params['name']
    @content = params['content']
    @is_approved = params['is_approved']
    @created_at = params['created_at']
  end

  # Returns only approved comments for public view
  def self.for_post(post_id)
    results = Database.query("SELECT * FROM comments WHERE post_id = ? AND is_approved = 1 ORDER BY created_at DESC", post_id)
    results.map { |row| new(row) }
  end

  # Returns all comments for admin moderation
  def self.all_with_posts
    results = Database.query("SELECT c.*, p.title as post_title FROM comments c JOIN posts p ON c.post_id = p.id ORDER BY c.created_at DESC")
    results.to_a
  end

  def self.find(id)
    results = Database.query("SELECT * FROM comments WHERE id = ?", id)
    row = results.first
    row ? new(row) : nil
  end

  def approve
    Database.query("UPDATE comments SET is_approved = 1 WHERE id = ?", @id)
  end

  def destroy
    Database.query("DELETE FROM comments WHERE id = ?", @id)
  end

  def save
    # Default is_approved is 0 via DB
    Database.query("INSERT INTO comments (post_id, name, content) VALUES (?, ?, ?)", @post_id, @name, @content)
    @id = Database.last_id
    true
  rescue => e
    puts "Error saving comment: #{e.message}"
    false
  end
end
