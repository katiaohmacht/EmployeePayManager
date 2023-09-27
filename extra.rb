Author: eward12 <Ewan.w.ward@gmail.com>  2023-09-27 10:35:20
Committer: eward12 <Ewan.w.ward@gmail.com>  2023-09-27 10:35:20
Parent: 0e4c46b0cd5beae6b4ce8ace2e9482371958c20d (Pay reports page in progress)
Parent: 604d95d12a452db48b92bdca5510b92495618344 (fixed password resetting)
Child:  fb989281a827ed39970ce9506d3a780d0cddad91 (I think i fixed it)
Branches: main, remotes/origin/main
Follows: 
Precedes: 

    Merge branch 'main' of https://github.com/katiaohmacht/EmployeePayManager

------------------------------------ app.rb ------------------------------------
index b844f7e,f2a2697..1ab5755
@@@ -488,22 -573,70 +573,4 @@@ post '/run_pay_period' d
    else 
      redirect '/pay_error'
    end
--end
--
- post '/view_pay_reports' do
-   redirect 'view_pay_reports'
 -get '/edit_employee_form' do
 -  @page_title = "Edit Employee"
 -  current_user
 -  if @current_user == nil || !@current_user.admin
 -    redirect '/admin_main'
 -  end
 -  @users = User.all
 -  erb :admin_main
--end
--
- get '/view_pay_reports' do
-   @page_title = "Pay Reports"
 -post '/navigate_clock' do
 -  redirect '/employee'
 -end
 -
 -post '/switch_work' do
 -  redirect '/view'
 -end
 -
 -post '/reset_button' do
--  current_user
-   if @current_user == nil || @current_user.admin == 0
-     redirect '/'
-   end
-   if @current_user.admin ==1
-     @users = User.where(admin: 0)
-   else
-     @users = User.all
 -
 -  user = User.find(@current_user.id)
 -  if user
 -    user.password = params[:psw]
 -    user.save
--  end
-   erb :pay_reports
 -
 -  redirect '/employee'
 -end
 -
 -
 -post '/resetpsw' do
 -  redirect '/reset'
 -end
 -