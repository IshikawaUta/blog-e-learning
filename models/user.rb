require 'bcrypt'
require_relative '../lib/database'

class User
  attr_accessor :id, :username, :password_digest

  def initialize(attributes = {})
    @id = attributes['id']
    @username = attributes['username']
    @password_digest = attributes['password_digest']
  end

  def self.authenticate(username, password)
    results = Database.query("SELECT * FROM users WHERE username = ?", username)
    row = results.first
    return nil unless row
    
    # Use bcrypt to compare password digest
    password_hash = BCrypt::Password.new(row['password_digest'])
    if password_hash == password
      new(row)
    else
      nil
    end
  rescue BCrypt::Errors::InvalidHash
    # Fallback for old plain-text passwords or malformed hashes
    nil
  end

  def self.find(id)
    results = Database.query("SELECT * FROM users WHERE id = ?", id)
    row = results.first
    row ? new(row) : nil
  end

  def password=(new_password)
    @password_digest = BCrypt::Password.create(new_password)
  end

  def save
    if @id
      Database.query("UPDATE users SET username = ?, password_digest = ? WHERE id = ?", @username, @password_digest, @id)
    else
      Database.query("INSERT INTO users (username, password_digest) VALUES (?, ?)", @username, @password_digest)
      @id = Database.last_id
    end
    self
  end
end
