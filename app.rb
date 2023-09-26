require 'sinatra'
require 'sinatra/activerecord'
require 'bcrypt'

require 'sqlite3'
require 'rake'
require 'pony'
require 'prawn'
require 'pdfkit'
require 'pp'
require 'time'

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

def isCheckedIn (user)
  time = Checktime.where(employee_id: user).last
  if time == nil 
    return 0
  elsif time.out
    return 0
  else
    return 1
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
  if @current_user == nil || @current_user.admin == 0
    redirect '/'
  end
  erb :add_employee
end

get '/pay_error' do
  @page_title = "Add Employee"
  current_user
  if @current_user == nil || @current_user.admin == 0
    redirect '/'
  end
  erb :pay_error
end

get '/pay_success' do
  @page_title = "Add Employee"
  current_user
  if @current_user == nil || @current_user.admin == 0
    redirect '/'
  end
  erb :pay_success
end

get '/edit_employees' do
  @page_title = "Edit Employees"
  current_user
  if @current_user == nil || @current_user.admin == 0
    redirect '/'
  end
  if @current_user.admin ==1
    @users = User.where(admin: 0)
  else
    @users = User.all
  end
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

post '/edit' do
  @page_title = "Edit Employee"
  current_user
  if @current_user == nil || @current_user.admin == 0
    redirect '/'
  end
  @employee = User.find(params[:user_id]) 
  erb :edit_employee_form
end



# Add a new route to handle the delete request
post '/delete_process' do
  current_user
  if @current_user == nil || @current_user.admin == 0
    redirect '/'
  end
  

  user_id = params[:user_id] # Assuming the name of the input field is 'user_id'
  
  # Find the user by ID and attempt to delete it
  user = User.find_by(id: user_id)
  if user
    user.active = 0
    user.save
  end

  redirect '/edit_employees' # Redirect back to the user list
end

# WORK HISTORY AND PAY PERIODS 
# -------------------------------------------------------------------------------------------

# Add a new route to handle generating and downloading the PDF
post '/work_history_process' do
  current_user
  if @current_user == nil || @current_user.admin == 0
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
    if user
      if user.hourly == 0
        salary = "/hr"
      else
        salary = "/yr"
      end
      pdf.move_down 20
      pdf.text "Employee ID: #{user.employee_id}", size: 14
      pdf.text "First Name: #{user.first_name}", size: 14 # Use the first name from params
      pdf.text "Last Name: #{user.last_name}", size: 14
      pdf.text "Occupation: #{user.job}", size: 14
      pdf.text "Salary: #{user.salary} #{salary}", size: 14
      pdf.text "Address: #{user.address}", size: 14

      a = Payperiod.last(2) 
      retrieve(pdf, user_id, Time.at(a[0].time), Time.at(a[1].time))
    end

    # Generate a unique filename for the PDF
    pdf_filename = "user_information_report_#{Time.now.strftime('%Y%m%d%H%M%S')}.pdf"

    # Save the PDF to a temporary file
    pdf.render_file(pdf_filename)

    # Send the PDF as an attachment for download
    send_file(pdf_filename, disposition: 'attachment', filename: pdf_filename, type: 'Application/pdf')
  rescue StandardError => e
    # Log any errors to the console or a log file
    pp "Error generating PDF: #{e.message}"
    # Optionally, you can render an error page or handle the error in another way
  end
end

def retrieve(pdf, id, start_date, end_date)
  times = Checktime.where(employee_id: id).where(time: start_date..end_date)
  current = start_date
  clock_in = current.to_i
  elapsed_time = 0.0
  str = ""
  total = 0.0
  regular = 0
  overtime = 0
  times.each do |time_entry|
    if time_entry.time < current.to_i || time_entry.time >= current.to_i+86400
      if time_entry.out
        elapsed_time += current.to_i+86400 - clock_in
        str += Time.at(clock_in).strftime("%l:%M %p") + "-" + Time.at(current.to_i+86400).strftime("%l:%M %p") + ", "
      end
        pdf.move_down 15
        pdf.text current.strftime("%A, %B, %d")
        pdf.text str
        pdf.text "#{(elapsed_time/3600).truncate(2)} hrs"
        pdf.move_down 15
        if elapsed_time > 9*3600 
          overtime += elapsed_time-9*3600
          regular += 9*3600
        else
          regular += elapsed_time
        end
        str = ""
        total += elapsed_time
        elapsed_time = 0.0
        current+=86400
        clock_in = current.to_i
    end
    if time_entry.out 
      elapsed_time += time_entry.time-clock_in
      str += Time.at(clock_in).strftime("%l:%M %p") + "-" + Time.at(time_entry.time).strftime("%l:%M %p") + ", "
    else 
      clock_in = time_entry.time
    end
  end
  if elapsed_time > 9*3600 
    overtime += elapsed_time-9*3600
    regular += 9*3600
  else
    regular += elapsed_time
  end
  total+= elapsed_time
  if total > 40*3600
    regular = 40*3600
    overtime = elapsed_time-40*3600
  end
  pdf.text current.strftime("%A, %B, %d")
  pdf.text str
  pdf.text "#{(elapsed_time/3600).truncate(2)} hrs"
  pdf.move_down 15
  
  pdf.text "Total hours worked: #{(total/3600).truncate(2)} hrs"
end

def pay(pdf, id, total, regular, overtime)
end

# -------------------------------------------------------------------------------------------


get '/admin_main' do
  @page_title = "Admin Main"
  current_user
  if @current_user == nil || @current_user.admin == 0
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
  if @current_user && @current_user.password == params[:psw] && @current_user.active != 0
    session[:user_id] = @current_user.id
    # if the boolean admin is true in the table, redirect to the admin main page
    if @current_user.admin != 0
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
    admin1 = params[:admin]
    if User.find(session[:user_id]).admin == 1
      admin1 = 0
    end
    # Save the sign-up information to the database
    @user = User.create(
      first_name: params[:first_name],
      last_name: params[:last_name],
      password: params[:psw],
      job: params[:job],
      salary: params[:salary],
      address: params[:address],
      employee_id: params[:employee_id],
      admin: admin1,
      hourly: params[:hourly],
      active: 1 
    )
    # Sign-up successful, redirect to main
    # session[:user_id] = @user.id
    redirect '/admin_main'
  end
end

# when clock in is clicked
post '/clockin' do
  current_user
  if isCheckedIn(@current_user.id) != 0
    redirect '/employee'
  else 
    
  # adds a log into the checktime table
  Checktime.create(
    employee_id: session[:user_id],
    time: Time.now,
    out: false
  )
  # brings user to confirmation page
  redirect '/confirmation_in'
  end
end

# when clock out is clicked
post '/clockout' do
  current_user
  # adds a log into the checktime table
  if isCheckedIn(@current_user.id) == 0
    redirect '/employee'
  else 
  Checktime.create(
    employee_id: session[:user_id],
    time: Time.now,
    out: true
  )
  # brigns user to confirmation page
  redirect '/confirmation_out'
  end
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

post '/update_employee' do
  user_id = params[:user_id] # Assuming the name of the input field is 'user_id'
  
  # Find the user by ID and attempt to delete it
  user = User.find(user_id)
  if user
    user.first_name = params[:first_name]
    user.last_name = params[:last_name]
    # user.password = params[:psw]
    user.job =params[:job]
    user.salary = params[:salary]
    user.address = params[:address]
    user.active = params[:active]
    # user.employee_id = params[:employee_id]
    user.admin = params[:admin]
    user.hourly = params[:hourly]
    user.save
  end
  
  redirect '/admin_main'

end

post '/auto_clock' do
  User.find_each do |entry|
    if isCheckedIn(entry.id) != 0
      Checktime.create(
        employee_id: entry.id,
        time: Time.now,
        out: true
      )
    end
  end
  redirect '/admin_main'
end

post '/home' do
  current_user
  if @current_user.admin != 0
    redirect '/admin_main'
  else
    redirect '/employee'
  end
end

post '/run_pay_period' do
  period1 = Payperiod.last
  if period1 != nil
    # If the pay period is run before 7 days after last, go away
    if period1.time + 7*3600*24 > Time.now.to_i
      redirect '/pay_error'
    else
      Payperiod.create(
        time: Time.now
      )
      redirect '/pay_success'
    end
  else 
    redirect '/pay_error'
  end
end