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
    #@session[:success] = msg
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

    sql = "SELECT todos.name FROM lists JOIN todos ON lists.id = todos.list"
    todos = @db.exec(sql)
    
    result.map do |tuple|
      list_id = tuple["id"]
      todo_sql = "SELECT * FROM lists WHERE id = $1"
      todos_result = @db.exec_params(todo_sql, [list_id])
      
      todos = todos_result.map do |todo_tuple|
        { id: todo_tuple["id"], 
          name: todo_tuple["name"], 
          completed: todo_tuple["completed"] }
      end
      
      { id: list_id, name: tuple["name"], todos: todos }
    end
    
  end

  def list(id)
    #@session[:lists][id]
    sql = "SELECT * FROM lists WHERE id = $1"
    puts "#{sql}: #{id}"
    result = @db.exec_params(sql, [id + 1]) #PRIMARY KEY starts at 1
    tuple = result.first
    { id: tuple["id"], name: tuple["name"], todos: [] }
  end

  def delete_list(id)
    #@session[:lists].delete_at(id)
  end

  def add_todo(list_id, todo)
    #@session[:lists][list_id][:todos] << todo
  end

  def add_list(list)
    #@session[:lists] << list
    
  end

  def list_matches(name)
    #@session[:lists].any? { |list| list[:name] == name }
  end
end