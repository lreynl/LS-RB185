require "sinatra"
require "sinatra/content_for"
require "tilt/erubis"
require_relative "database_persistence"
#require_relative "session_persistence"

set :bind, '0.0.0.0'

configure do
  enable :sessions
  #set :sessions, true
  set :session_secret, 'secret'
end

configure(:development) do
  require "sinatra/reloader"
  also_reload './database_persistence.rb'
end

before do
  @storage = DatabasePersistence.new
end

helpers do
  def list_complete?(list)
    list[:todos].size > 0 && list[:todos].all? { |todo| todo[:completed] }
  end

  def list_class(list)
    "complete" if list_complete?(list)
  end

  def todos_remaining_count(list)
    list[:todos].select { |todo| todo[:completed] }.size.to_s
  end

  def sort_list(lists, &block)
    complete_lists, incomplete_lists = lists.partition { |list| list_complete?(list) }
    incomplete_lists.each { |list| yield list, lists.index(list) }
    complete_lists.each { |list| yield list, lists.index(list) }
  end

  def sort_todos(todos, &block)
    complete_todos, incomplete_todos = todos.partition { |todo| todo[:completed] }
    incomplete_todos.each { |todo| yield todo, todos.index(todo) }
    complete_todos.each { |todo| yield todo, todos.index(todo) }
  end

end

def load_list(id)
  list = @storage.find_list(id)
  return list if list
  @storage.set_error("That list wasn't found")
  redirect "/lists"
end

get "/" do
  redirect "/lists"
end

get "/lists" do
  #@lists = session[:lists]
  @lists = @storage.lists
  erb :lists, layout: :layout
end

get "/lists/new" do
  erb :new_list, layout: :layout
end

get "/lists/:id" do
  @list_id = params[:id].to_i
  #@list = session[:lists][@list_id]
  @list = @storage.list(@list_id)
  erb :list, layout: :layout
end

get "/lists/:id/edit" do
  id = params[:id].to_i
  #@list = session[:lists][id]
  @list = @storage.list(id)
  erb :edit_list, layout: :layout
end 

post "/lists/:id" do
  list_name = params[:list_name].strip
  error = error_for_list_name(list_name)
  id = params[:id].to_i
  #@list = session[:lists][id]
  @list = @storage.list(id)
  if error
    session[:error] = error
    #@storage.set_error(error)
    erb :new_list, layout: :layout
  else
    #@list[:name] = list_name
    @storage.update(id, list_name)
    session[:success] = "The list has been updated."
    #@storage.set_success("The list has been updated.")
    redirect "/lists/#{id}"
  end
end

post "/lists/:id/delete" do
  id = params[:id].to_i
  #session[:lists].delete_at(id)
  @storage.delete_list(id)
  #@storage.set_success("List was deleted.")
  session[:success] = "List was deleted."
  redirect "/lists"
end

def error_for_todo_name(text)
  if !(1..100).cover? text.length
    "Todo name must be between 1 and 100 characters"
  end  
end

def error_for_list_name(name)
  if !(1..100).cover? name.length
    "List name must be between 1 and 100 characters"
  #elsif session[:lists].any? { |list| list[:name] == name }
  elsif @storage.list_matches(name)
    "List name must be unique"
  end
end

post "/lists" do
  list_name = params[:list_name].strip
  error = error_for_list_name(list_name)
  if error
    #@storage.set_error(error)
    session[:error] = error
    erb :new_list, layout: :layout
  else
    #session[:lists] << { name: list_name, todos: [] }
    #list = { name: list_name, todos: [] }
    @storage.add_list(list_name)
    #@storage.set_success("The list has been created.")
    session[:success] = "The list has been created."
    redirect "/lists"
  end
end

post "/lists/:list_id/todos" do
  @list_id = params[:list_id].to_i || params[:id].to_i
  todo_name = params[:todo].strip
  #@list = session[:lists][@list_id]
  @list = @storage.list(@list_id)
  error = error_for_todo_name(todo_name)
  if error
    session[:error] = error
    #@storage.set_error(error)
    erb :list, layout: :layout
  else
    #session[:lists][@list_id][:todos] << { name: text, completed: false } 
    #todo = { name: text, completed: false } 
    @storage.add_todo(@list_id, todo_name)
    session[:success] = "Todo item has been added."
    #@storage.set_success("Todo item has been added.")
    redirect "/lists/#{@list_id}"
  end
end

post "/lists/:list_id/delete_todo/:todo_id" do
  list_id = params[:list_id].to_i
  todo_id = params[:todo_id].to_i
  #deleted = session[:lists][list_id][:todos].delete_at(todo_id)[:name]
  @storage.delete_todo(todo_id)
  #@storage.set_success("Todo was deleted")
  session[:success] = "Todo was deleted."
  redirect "/lists/#{list_id}"
end

post "/lists/:list_id/toggle/:todo_id" do
  list_id = params[:list_id].to_i
  todo_id = params[:todo_id].to_i
  is_completed = params[:completed] == 'true'
  #session[:lists][list_id][:todos][todo_id][:completed] = is_completed
  @storage.todo_completed(todo_id, is_completed)
  #@storage.set_success("Todo has been updated")
  session[:success] = "Todo has been updated."
  redirect "/lists/#{list_id}"
end

post "/lists/:list_id/complete_all" do
  list_id = params[:list_id].to_i
  #session[:lists][list_id][:todos].each do |todo_item|
  @storage.complete_all(list_id)
  #@storage.set_success("All todos have been completed.")
  session[:success] = "All todos have been completed."
  redirect "/lists/#{list_id}"
end