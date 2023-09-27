require 'sinatra'
require 'sinatra/activerecord'
require 'bcrypt'

require 'sqlite3'
require 'rake'
require 'pony'
require 'prawn'
require 'pdfkit'
require 'pp' #for debugging purposes
require 'time'
require 'holidays'
require 'date'
require 'holidays/core_extensions/date'

class Date
  include Holidays::CoreExtensions::Date
end

gem 'pony'

#set your database
set :database, {adapter: "sqlite3", database: "cooldb.sqlite3"}

set :sessions, true
set :logging, true

require './models'

#Function to check if a current user is logged in, if not redirects to login page.
def current_user
  if session[:user_id]
    #if the user is not logged in 
    if User.find(session[:user_id]).blank? then @current_user = nil else @current_user = User.find(session[:user_id]) 
    end
  else
    session.clear
    @current_user = nil
  end
end

# Function that returns 0 if the user's last time check was out, 1 if in
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

# Index erb
get '/' do
  @page_title = "Home"
  current_user
  erb :index
end

# Add employee erb with admin check
get '/add_employee' do
  @page_title = "Add Employee"
  current_user
  if @current_user == nil || @current_user.admin == 0
    redirect '/'
  end
  erb :add_employee
end

# Pay error erb with admin check
get '/pay_error' do
  @page_title = "Add Employee"
  current_user
  if @current_user == nil || @current_user.admin == 0
    redirect '/'
  end
  erb :pay_error
end

# Pay success erb
get '/pay_success' do
  @page_title = "Add Employee"
  current_user
  if @current_user == nil || @current_user.admin == 0
    redirect '/'
  end
  erb :pay_success
end

# Edit employees page with admin level check
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
  # tester
  erb :edit_employees
end

get '/view' do
  @page_title = "Work History"
  current_user
  if @current_user == nil || !@current_user.admin
    redirect '/'
  end
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

get '/edit_employee_form' do
  @page_title = "Edit Employee"
  current_user
  if @current_user == nil || !@current_user.admin
    redirect '/admin_main'
  end
  @users = User.all
  erb :admin_main
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
        salary = "/yr"
      else
        salary = "/hr"
      end
      pdf.move_down 20
      pdf.text "#{user.first_name} #{user.last_name}", size: 20, style: :italic, color: '0000FF', background_color: 'FFFF00'
      pdf.move_down 5
      pdf.text "Employee ID: #{user.employee_id}", size: 20, style: [:bold, :italic], color: '007700'
      pdf.move_down 5
      pdf.text "Occupation: #{user.job}", size: 20, style: :bold
      pdf.move_down 5
      pdf.text "Salary: #{user.salary} #{salary}", size: 20, style: :bold, color: 'FF0000'
      pdf.move_down 5
      pdf.text "Address: #{user.address}", size: 20
      pdf.move_down 20
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

# Retreives and displays the times and days of each check in and out
def retrieve(pdf, id, start_date, end_date)
  times = Checktime.where(employee_id: id).where(time: start_date..end_date)
  # 40h * number of weeks
  threshold = 40.0*(end_date - start_date)*3600.0/86400.0/7.0
  current = start_date
  clock_in = current.to_i
  elapsed_time = 0.0
  str = ""
  total = 0.0
  regular = 0
  overtime = 0
  regular_holiday = 0
  overtime_holiday = 0
  times.each do |time_entry|
    # pdf.text Time.at(time_entry.time).strftime("%Y-%m-%d %H:%M:%S %z") 
    while time_entry.time >= current.to_i+86400
      if time_entry.out
        elapsed_time += current.to_i+86400 - clock_in
        str += Time.at(clock_in).strftime("%l:%M %p") + "-" + Time.at(current.to_i+86400).strftime("%l:%M %p") + ", "
      end
        pdf.move_down 5
        pdf.text current.strftime("%A, %B, %d")
        pdf.text str
        pdf.text "#{(elapsed_time/3600).truncate(2)} hrs"
        pdf.move_down 5

        reg = elapsed_time
        if elapsed_time > 9*3600
          reg = 9*3600
        end
        if total + elapsed_time > threshold
          reg = threshold - (regular + regular_holiday)
        end
        
        over = elapsed_time-reg
       # pdf.text "#{over} #{reg}"
        holiday = isHoliday(current)
        if holiday 
          overtime_holiday+= over
          regular_holiday += reg
        else
          overtime += over
          regular += reg
        end
        
        total += elapsed_time
        elapsed_time = 0.0
        str = ""
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
  reg = elapsed_time
  if elapsed_time > 9*3600
    reg = 9*3600
  end
  if total + elapsed_time > threshold
    #we are above threshold
    reg = threshold - (regular + regular_holiday)
    # if reg < 0
    #   reg = 0
    # end
  end
  
  over = elapsed_time-reg
  #pdf.text "#{over} #{reg}"
  holiday = isHoliday(current)
  if holiday 
    overtime_holiday+= over
    regular_holiday += reg
  else
    overtime += over
    regular += reg
  end
  total+= elapsed_time

  pdf.move_down 15
  pdf.text current.strftime("%A, %B, %d")
  pdf.move_down 5
  pdf.text str
  pdf.move_down 5
  pdf.text "#{(elapsed_time/3600).truncate(2)} hrs"
  pdf.move_down 5
  
  pdf.text "Total hours worked: #{(total/3600).truncate(2)} hrs"
  pay(pdf, id, total, regular, overtime, regular_holiday, overtime_holiday)
end

def isHoliday(time)
  holidayList = ["Christmas", "Easter", "Juneteenth", "New Year\'s Day", "Thanksgiving"]
  day = time.day
  month = time.month
  year = time.year
  holiday = Date.civil(year, month, day).holidays(:us)
  if holiday == nil
    return false
  end
  holidayList.each do |entry| 
    holiday.each do |entry2|
      if entry == entry2[:name]
        return true
      end
    end
  end
  return false
end

# Displays the total pay for the employee on the pdf depending on salary or hourly
def pay(pdf, id, total, regular, overtime, regular_holiday, overtime_holiday)
  user = User.find_by(id: id)
  salary = user.salary 
  bool_hourly = false 
  if user.hourly != 0
    bool_hourly = true
  end
  if bool_hourly 
    end_pay = (regular+overtime*1.5 + regular_holiday*2 + overtime_holiday*3.0)/3600.0*salary
    pdf.text "Net pay: $#{end_pay}"
  else #salary calculation
    last_two = Payperiod.last(2)
    # Days in the pay period
    days = (last_two[1].time - last_two[0].time)/(3600.0*24) 
    factor = 1.0
    weekly_salary = salary/52.0
    if (total/3600.0)<(40.0*days/7.0)
      factor = (total/3600.0)/(40.0*days/7.0)
    end
    # pdf.text " weekly salary: #{weekly_salary} days: #{days} factor: #{factor} total: #{total} " TESTING
    end_pay = (days/7.0)*weekly_salary*factor
    pdf.text "Net pay: $#{end_pay.truncate(2)}"
  end
end

# -------------------------------------------------------------------------------------------

# Admin main erb page 
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

get '/reset' do
  @page_title = "Reset Password"
  current_user
  if @current_user == nil
    redirect '/'
  end

  erb :reset
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

# Adding an employee process
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
    session[:user_id] = @user.id
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

post '/take_to_login' do
  redirect '/login'
end

# Updates employees 
post '/update_employee' do
  user_id = params[:user_id] # Assuming the name of the input field is 'user_id'
  
  # Find the user by ID and update its fields
  user = User.find(user_id)
  if user
    user.first_name = params[:first_name]
    user.last_name = params[:last_name]
    user.password = params[:psw]
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

# Auto clocks out all the employees who are not clocked out
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

# brings the user to the home page of their respective level
post '/home' do
  current_user
  if @current_user.admin != 0
    redirect '/admin_main'
  else
    redirect '/employee'
  end
end

# runs the pay period, adding a new entry to the table
post '/run_pay_period' do
  period1 = Payperiod.last
  if period1 != nil
    # If the pay period is run before 7 days after last, go away 
    # if period1.time + 7*3600*24 > Time.now.to_i
    #   redirect '/pay_error'
    # else
      Payperiod.create(
        time: Time.now
      )
      redirect '/pay_success'
    # end
  else 
    redirect '/pay_error'
  end
end