class SessionPersistence
  def initialize(session)
    @session = session
    session[:lists] ||= []
  end

  def find_list(id)
    @session[:lists].find { |list| list[:id] == id }
  end

  def set_error(msg)
    @session[:error] = msg
  end

  def set_success(msg)
    @session[:success] = msg
  end

  def get_success
    @session[:success]
  end

  def get_error
    @session[:error]
  end

  def delete_success
    @session.delete(:success)
  end  

  def delete_error
    @session.delete(:error)
  end

  def todos(list_id)
    @session[:lists][list_id][:todos]
  end

  def todo_completed(list_id, todo_id, completed)
    @session[:lists][list_id][:todos][todo_id][:completed] = completed
  end

  def delete_todo(list_id, todo_id)
    @session[:lists][list_id][:todos].delete_at(todo_id)[:name]
  end

  def lists
    @session[:lists]
  end

  def list(id)
    @session[:lists][id]
  end

  def delete_list(id)
    @session[:lists].delete_at(id)
  end

  def add_todo(list_id, todo)
    @session[:lists][list_id][:todos] << todo
  end

  def add_list(list)
    @session[:lists] << list
  end

  def list_matches(name)
    @session[:lists].any? { |list| list[:name] == name }
  end
end