require 'sinatra'
require 'sinatra/activerecord'
require 'bcrypt'

require 'sqlite3'
require 'rake'
require 'pony'
require 'prawn'
require 'pdfkit'
gem 'pony'

#set your database
set :database, {adapter: "sqlite3", database: "cooldb.sqlite3"}

set :sessions, true
set :logging, true


require './models'

#Function to check if a current user is logged in, if not redirects to login page.
def current_user
  if session[:user_id]
    if User.find(session[:user_id]).blank? then @current_user = nil else @current_user = User.find(session[:user_id]) 
    end
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

get '/add_employee' do
  @page_title = "Add Employee"
  current_user
  if @current_user == nil || !@current_user.admin
    redirect '/'
  end
  erb :add_employee
end

get '/edit_employees' do
  @page_title = "Edit Employees"
  current_user
  if @current_user == nil || !@current_user.admin
    redirect '/'
  end
  @users = User.all
  erb :edit_employees
end

get '/view' do
  @page_title = "Work History"
  current_user
  #if @current_user == nil || !@current_user.admin
  #  redirect '/'
 # end
  @users = User.all
  erb :view
end


# Add a new route to handle the delete request
post '/delete_process' do
  current_user
  if @current_user == nil || !@current_user.admin
    redirect '/'
  end
  

  user_id = params[:user_id] # Assuming the name of the input field is 'user_id'
  
  # Find the user by ID and attempt to delete it
  user = User.find_by(id: user_id)
  if user
    user.destroy
  end

  redirect '/edit_employees' # Redirect back to the user list
end


# Add a new route to handle generating and downloading the PDF
post '/work_history_process' do
  current_user
  if @current_user == nil || !@current_user.admin
    redirect '/'
  end

  # Find user by ID
  user_id = params[:user_id]
  user = User.find_by(id: user_id)

  # Retrieve the first name from the parameters
  first_name = params[:first_name]

  begin
    # Create a PDF document
    pdf = Prawn::Document.new

    # Add user information to the PDF, including the first name
    pdf.text "Work History Report", size: 18, style: :bold, align: :center
    pdf.text "First name: #{first_name}", size:14
    if user
      pdf.move_down 20
      pdf.text "Employee ID: #{user.employee_id}", size: 14
      pdf.text "First Name: #{first_name}", size: 14 # Use the first name from params
      pdf.text "Last Name: #{user.last_name}", size: 14
      pdf.text "Occupation: #{user.job}", size: 14
      pdf.text "Salary: #{user.salary}", size: 14
    end

    # Generate a unique filename for the PDF
    pdf_filename = "user_information_report_#{Time.now.strftime('%Y%m%d%H%M%S')}.pdf"

    # Save the PDF to a temporary file
    pdf.render_file(pdf_filename)

    # Send the PDF as an attachment for download
    send_file(pdf_filename, disposition: 'attachment', filename: pdf_filename)
  rescue StandardError => e
    # Log any errors to the console or a log file
    puts "Error generating PDF: #{e.message}"
    # Optionally, you can render an error page or handle the error in another way
  end
end




get '/admin_main' do
  @page_title = "Admin Main"
  current_user
  if @current_user == nil || !@current_user.admin
    redirect '/'
  end
  erb :admin_main
end

get '/employee' do
  @page_title = "Employee"
  current_user
  if @current_user == nil
    redirect '/'
  end
  erb :employee
end

get '/login' do
  @page_title = "Login"
  if @current_user != nil
    redirect '/'
  end
  erb :login
end

# Redirect page for confirmations
get '/confirmation_out' do
  @page_title = "Confirmation Out"
  erb :confirmation_out
end

get '/confirmation_in' do
  @page_title = "Confirmation In"
  erb :confirmation_in
end


#validate login credentials for user
post '/login_process' do
  @current_user = User.find_by(employee_id: params[:id])
  # if the current user is a valid user, create a session
  if @current_user && @current_user.password == params[:psw]
    session[:user_id] = @current_user.id
    # if the boolean admin is true in the table, redirect to the add employee page
    if @current_user.admin 
      redirect '/admin_main'
    else #if not, then redirect to employee page
      redirect '/employee'
    end
  else
    redirect '/'  # Redirect to the login-failed route if login fails
    session.clear
  end
end

post '/sign_up_process' do
  # Check if user exists with the given ID
  existing_user = User.find_by(employee_id: params[:employee_id])
  
  if existing_user
    redirect '/add_employee'
  else
    # Save the sign-up information to the database
    @user = User.create(
      first_name: params[:first_name],
      last_name: params[:last_name],
      password: params[:psw],
      job: params[:job],
      salary: params[:salary],
      address: params[:address],
      employee_id: params[:employee_id],
      admin: params[:admin]
    )
    # Sign-up successful, redirect to index
    session[:user_id] = @user.id
    redirect '/'
  end
end

# when clock in is clicked
post '/clockin' do
  # adds a log into the checktime table
  Checktime.create(
    employee_id: session[:user_id],
    time: Time.now,
    out: false
  )
  # brings user to confirmation page
  redirect '/confirmation_in'
end

# when clock out is clicked
post '/clockout' do
  # adds a log into the checktime table
  Checktime.create(
    employee_id: session[:user_id],
    time: Time.now,
    out: true
  )
  # brigns user to confirmation page
  redirect '/confirmation_out'
end

# when sign out button pressed, clears user and redirects to home
post '/signout' do
  session.clear
  redirect '/'
end

post '/new_user' do
  redirect '/add_employee'
end

post '/edit_employees' do
  redirect '/edit_employees'
end

