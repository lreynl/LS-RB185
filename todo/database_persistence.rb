require 'pg'

class DatabasePersistence
  def initialize
    @db = PG.connect(dbname: "todos")
  end

  def find_list(id)
    #@session[:lists].find { |list| list[:id] == id }
  end

  def set_error(msg)
    session[:error] = msg
    
  end

  def set_success(msg)
    session[:success] = msg
    
  end

  def get_success
    session[:success]
  end

  def get_error
    session[:error]
  end

  def delete_success
    session.delete(:success)
  end  

  def delete_error
    session.delete(:error)
  end

  def todos(list_id)
    #@session[:lists][list_id][:todos]
    sql = "SELECT * FROM todos WHERE list = $1"
    result = @db.exec_params(sql, [list_id])
    result.map do |tuple|
      todo_id = tuple["id"]
      { id: todo_id, name: tuple["name"], completed: tuple["completed"] }
    end
  end

  def todo_completed(todo_id, is_completed)
    sql = "UPDATE todos SET completed = $1 WHERE id = $2"
    @db.exec_params(sql, [is_completed, todo_id])
  end

  def complete_all(list_id)
    sql = "UPDATE todos SET completed = $1 WHERE list = $2"
    @db.exec_params(sql, [true, list_id])
  end

  def delete_todo(todo_id)
    sql = "DELETE FROM todos WHERE id = $1"
    @db.exec_params(sql, [todo_id])
  end

  def lists
    sql = "SELECT * FROM lists"
    result = @db.exec(sql)
    
    result.map do |tuple|
      list_id = tuple["id"]
      todos = find_todos_for_list(list_id)
      { id: list_id, name: tuple["name"], todos: todos }
    end
    
  end

  def list(id)
    sql = "SELECT * FROM lists WHERE id = $1"
    puts "#{sql}: #{id}"
    result = @db.exec_params(sql, [id])
    tuple = result.first
    list_id = tuple["id"].to_i
    todos = find_todos_for_list(list_id)
    { id: list_id, name: tuple["name"], todos: todos }
  end

  def update(list_id, list_name)
    sql = "UPDATE lists SET name = $1 WHERE id = $2"
    @db.exec_params(sql, [list_name, list_id])
    
  end

  def delete_list(id)
    sql = "DELETE FROM lists WHERE id = $1"
    @db.exec_params(sql, [id])
    sql = "DELETE FROM todos WHERE list = $1"
    @db.exec_params(sql, [id])
  end

  def add_todo(list_id, todo_name)
    sql = "INSERT INTO todos (name, completed, list) VALUES ($1, $2, $3)"
    @db.exec_params(sql, [todo_name, false, list_id])
  end

  def add_list(list_name)
    sql = "INSERT INTO lists (name) VALUES ($1)"
    @db.exec_params(sql, [list_name])
  end

  def list_matches(name)
    #@session[:lists].any? { |list| list[:name] == name }
    sql = "SELECT name FROM lists WHERE lists.name = $1"
    @db.exec_params(sql, [name])
  end

  private

  def find_todos_for_list(list_id)
    todo_sql = "SELECT * FROM todos WHERE list = $1"
    todos_result = @db.exec_params(todo_sql, [list_id])
    todos_result.map do |todo_tuple|
      { id: todo_tuple["id"].to_i, 
        name: todo_tuple["name"], 
        completed: todo_tuple["completed"] == 't' }
    end
  end
end