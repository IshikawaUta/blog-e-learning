require 'mysql2'
require 'bcrypt'
begin
  require 'dotenv'
  Dotenv.load
rescue LoadError
  # Dotenv not installed, assuming env vars set manually or via system
end

class Database
  def self.client
    @client ||= Mysql2::Client.new(
      host:     ENV['DB_HOST'] || 'localhost',
      username: ENV['DB_USER'] || 'root',
      password: ENV['DB_PASS'] || '',
      database: ENV['DB_NAME'] || 'elearning_db'
    )
  rescue Mysql2::Error
    # Fallback to connect without database if it doesnt exist yet
    @client = Mysql2::Client.new(
      host:     ENV['DB_HOST'] || 'localhost',
      username: ENV['DB_USER'] || 'root',
      password: ENV['DB_PASS'] || ''
    )
  end

  def self.query(sql, *args)
    client.prepare(sql).execute(*args)
  end

  def self.last_id
    client.last_id
  end

  def self.setup
    begin
      db_name = ENV['DB_NAME'] || 'elearning_db'
      c = Mysql2::Client.new(
        host:     ENV['DB_HOST'] || 'localhost',
        username: ENV['DB_USER'] || 'root',
        password: ENV['DB_PASS'] || ''
      )
      c.query("CREATE DATABASE IF NOT EXISTS #{db_name}")
      puts "Database #{db_name} created or already exists."
    rescue => e
      puts "Error creating database: #{e.message}"
    end

    db_client = Mysql2::Client.new(
      host:     ENV['DB_HOST'] || 'localhost',
      username: ENV['DB_USER'] || 'root',
      password: ENV['DB_PASS'] || '',
      database: ENV['DB_NAME'] || 'elearning_db'
    )
    
    # Create Users Table
    db_client.query <<-SQL
      CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        username VARCHAR(255) NOT NULL UNIQUE,
        password_digest VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    SQL

    # Create Categories Table
    db_client.query <<-SQL
      CREATE TABLE IF NOT EXISTS categories (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL UNIQUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    SQL

    # Create Posts Table (updated with category_id and FULLTEXT index)
    db_client.query <<-SQL
      CREATE TABLE IF NOT EXISTS posts (
        id INT AUTO_INCREMENT PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        content TEXT NOT NULL,
        thumbnail_url VARCHAR(255),
        thumbnail_public_id VARCHAR(255),
        author_id INT,
        category_id INT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (author_id) REFERENCES users(id),
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
        FULLTEXT (title, content)
      ) ENGINE=InnoDB
    SQL

    # Create Comments Table (updated with is_approved)
    db_client.query <<-SQL
      CREATE TABLE IF NOT EXISTS comments (
        id INT AUTO_INCREMENT PRIMARY KEY,
        post_id INT NOT NULL,
        name VARCHAR(255) NOT NULL,
        content TEXT NOT NULL,
        is_approved BOOLEAN DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
      )
    SQL

    # Migrations for existing tables
    begin
      db_client.query("ALTER TABLE posts ADD COLUMN category_id INT AFTER author_id")
      db_client.query("ALTER TABLE posts ADD FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL")
      puts "Column category_id added to posts."
    rescue
      # Column probably already exists
    end

    begin
      db_client.query("ALTER TABLE posts ADD FULLTEXT(title, content)")
      puts "Full-text index added to posts."
    rescue
      # Index probably already exists
    end

    begin
      db_client.query("ALTER TABLE comments ADD COLUMN is_approved BOOLEAN DEFAULT 0 AFTER content")
      puts "Column is_approved added to comments."
    rescue
      # Column probably already exists
    end

    # Seed Admin User (password: admin123)
    # Using BCrypt for secure hashing
    password_hash = BCrypt::Password.create("admin123")
    
    begin
      db_client.query("INSERT INTO users (username, password_digest) VALUES ('admin', '#{password_hash}')")
      puts "Admin user seeded."
    rescue
      puts "Admin user already exists."
    end
  end
end
