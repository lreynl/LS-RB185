require 'pg'

class DatabasePersistence
  def initialize
    @db = PG.connect(dbname: "todos")
  end

  def find_list(id)
    #@session[:lists].find { |list| list[:id] == id }
  end

  def set_error(msg)
    #@session[:error] = msg
    
  end

  def set_success(msg)
    #session[:success] = msg
    
  end

  def get_success
    #@session[:success]
  end

  def get_error
    #@session[:error]
  end

  def delete_success
    #@session.delete(:success)
  end  

  def delete_error
    #@session.delete(:error)
  end

  def todos(list_id)
    #@session[:lists][list_id][:todos]
  end

  def todo_completed(list_id, todo_id, completed)
    #@session[:lists][list_id][:todos][todo_id][:completed] = completed
  end

  def delete_todo(list_id, todo_id)
    #@session[:lists][list_id][:todos].delete_at(todo_id)[:name]
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
    #@session[:lists][id]
    sql = "SELECT * FROM lists WHERE id = $1"
    puts "#{sql}: #{id}"
    result = @db.exec_params(sql, [id])
    tuple = result.first
    list_id = tuple["id"].to_i
    todos = find_todos_for_list(list_id)
    { id: list_id, name: tuple["name"], todos: todos }
  end

  def delete_list(id)
    #@session[:lists].delete_at(id)
    sql = "DELETE FROM lists WHERE id = $1"
    @db.exec_params(sql, [id])
    sql = "DELETE FROM todos WHERE list = $1"
    @db.exec_params(sql, [id])
  end

  def add_todo(list_id, todo)
    #@session[:lists][list_id][:todos] << todo
  end

  def add_list(list_name)
    #@session[:lists] << list
    sql = "INSERT INTO lists (name) VALUES ($1)"
    @db.exec_params(sql, [list_name])
  end

  def list_matches(name)
    #@session[:lists].any? { |list| list[:name] == name }
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