require 'sinatra'
require 'sinatra/activerecord'
require 'bcrypt'

require 'sqlite3'
require 'rake'
require 'pony'
gem 'pony'

#set your database
set :database, {adapter: "sqlite3", database: "cooldb.sqlite3"}

set :sessions, true
set :logging, true


require './models'

#Function to check if a current user is logged in, if not redirects to login page.
def current_user
  if session[:user_id]
    if User.find(session[:user_id]).blank? then @current_user = nil else @current_user = User.find(session[:user_id]) end
  else
    session.clear
    @current_user = nil
  end
end

get '/' do
  @page_title = "Home"
  current_user
  erb :index
end




get '/sign_up' do
  @page_title = "Sign Up"
  current_user
  if @current_user != nil
    redirect '/'
  end
  erb :sign_up
end

get '/login' do
  @page_title = "Login"
  if @current_user != nil
    redirect '/'
  end
  erb :login
end



#validate login credentials for user
post '/login_process' do
  @current_user = User.find_by(password: params[:psw].downcase)
  
  if @current_user && @current_user.password == params[:psw]
    session[:user_id] = @current_user.id
    redirect '/'
  else
    redirect '/login'  # Redirect to the login-failed route if login fails
  end
end


post '/sign_up_process' do
  # Check if user exists with the given ID
  if User.find_by(employee_id: params[:employee_id].downcase)
    redirect '/sign_up'
  else
    # Save the sign-up information to the database
    @user = User.create(
      first_name: params[:first_name].downcase,
      last_name: params[:last_name].downcase,
      password: params[:psw],
      job: params[:job].downcase,
      salary: params[:salary].downcase,
      address: params[:address].downcase,
      employee_id: params[:employee_id].downcase

    )
    # Sign-up successful, redirect to index 
    session[:user_id] = @user.id
    redirect '/'
  end
end
