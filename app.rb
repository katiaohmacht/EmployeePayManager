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

get '/puzzle' do
  @page_title = "Puzzle"
  current_user
  erb :puzzle
end
get '/bubble' do
  @page_title = "Bubble Art"
  current_user
  erb :bubble
end

get '/logout' do
  session.clear
  redirect '/login'
end

get '/emotion_wheel' do
  @page_title = "Emotion Wheel"
  current_user
  erb :emotion_wheel
end

post '/reflection_process' do
  current_user

  reflection = Reflection.create(rgb: params[:rgb], summary: params[:summary], user_id: @current_user.id)
  @reflections = @current_user.reflections

  redirect '/dashboard'
end

post '/color_process' do
  current_user
  rgb = params[:rgb]

  
  # Save the RGB value or pass it to the dashboard.erb template as needed
  
  # Redirect to the dashboard
  redirect '/dashboard'
end


get '/draw' do
  @page_title = "Draw"
  current_user
 # @edit_button_clicked = params[:edit_button_clicked] || false
  erb :draw
end


get '/dashboard' do
  @page_title = "Dashboard"
  current_user
  @reflections = @current_user.reflections.where.not(rgb: "", summary: "")

  user_folder = "public/user_drawings/#{session[:user_id]}"

  # Retrieve the drawings with their RGB values
  @drawings = Drawing.where(user_id: session[:user_id]).where.not(rgb: "").select do |drawing|
    image_file_exists = File.exist?(drawing.path)
    puts "Drawing: #{drawing.name} | Path: #{drawing.path} | Image File Exists: #{image_file_exists}"
    image_file_exists
  end

  erb :dashboard, locals: { reflections: @reflections, drawings: @drawings }
end








# Update the route for deleting a reflection
delete '/delete/:reflection_id' do
  current_user
  reflection = Reflection.find_by(id: params[:reflection_id], user_id: @current_user.id)
  reflection.destroy if reflection

  redirect '/dashboard'
end



delete '/delete_drawing/:filename' do
  filename = params[:filename]
  user_id = session[:user_id]
  drawing_path = "public/user_drawings/#{user_id}/#{filename}"

  # Check if the file exists
  if File.exist?(drawing_path)
    # Delete the file
    File.delete(drawing_path)

    # Remove the directory if it's empty
    dir_path = "public/user_drawings/#{user_id}"
    Dir.delete(dir_path) if Dir.empty?(dir_path)

    redirect '/dashboard'
  else
    # Handle file not found error
    status 404
    'File not found'
  end
end





# Add a route to handle the edit button click
post '/edit_drawing/:drawing_name' do
  current_user
  @drawing_name = params[:drawing_name]
  @drawing_path = "public/user_drawings/#{session[:user_id]}/#{@drawing_name}"
  @edit_button_clicked = true
  user_folder = "public/user_drawings/#{session[:user_id]}"
 # Retrieve the drawing from the database based on the drawing name
  drawing = Drawing.find_by(name: @drawing_name, user_id: session[:user_id])

  # Pass the RGB value of the drawing to the template
  @rgb = drawing.rgb

  @drawings = [@drawing_path]
  erb :draw, locals: {rgb: @rgb}
end







get '/contact' do
  @page_title = "Contact"
  current_user
  erb :contact
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



post '/save' do
  current_user
  # Create the user folder if it doesn't exist
  user_folder = "public/user_drawings/#{session[:user_id]}"
  FileUtils.mkdir_p(user_folder) unless File.exist?(user_folder)

  # Generate a unique file name for the drawing
  file_name = "drawing_#{Time.now.to_i}.png"
  file_path = File.join(user_folder, file_name)

  # Decode the base64 data and save the drawing image to the specified path
  File.open(file_path, 'wb') do |file|
    file.write(Base64.decode64(params[:drawing].split(',')[1]))
  end

  # Create a new drawing record in the database with the associated RGB value
  drawing = Drawing.create(name: file_name, path: file_path, user_id: session[:user_id])

  # Update the RGB value for the drawing
  drawing.update(rgb: params[:rgb])

  @drawings = @current_user.drawings
  redirect '/dashboard'
end




post '/send_message' do
  sender_name = params[:sender_name]
  message_text = params[:message]

  # Save the message to a text file
  File.open('messages.txt', 'a') do |file|
    file.puts("Sender: #{sender_name}")
    file.puts("Message: #{message_text}")
    file.puts("-" * 20)  # Add a separator between messages
  end

  redirect '/contact', notice: 'Message sent successfully!'
end

get '/view_messages' do
  @messages = []

  if File.exist?('messages.txt')
    File.foreach('messages.txt') do |line|
      @messages << line.chomp
    end
  end

  erb :view_messages
end





#validate login credentials for user
post '/login_process' do
  @current_user = User.find_by(employee_id: params[:employee_id].downcase)
  
  if @current_user && @current_user.password == params[:psw]
    session[:user_id] = @current_user.id
    redirect '/'
  else
    redirect '/login'  # Redirect to the login-failed route if login fails
  end
end


post '/sign_up_process' do
  # Check if user exists with the given ID
  if User.find_by(id: params[:id].downcase)
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
    # Sign-up successful, redirect to dashboard or another page
    session[:user_id] = @user.id
    redirect '/dashboard'
  end
end
