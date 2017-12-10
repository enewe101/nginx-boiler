This repository sets up a boilerplate installation of nginx that runs inside a docker instance.  Use it as a starting point for your new app.  

Follow these steps to configure this repo to be the starting point for your new
app:

1) Associate this to a new repo for your project:

		$ git remote rm origin
		$ git remote add origin <uri for new repo>
		$ git push -u origin master

4) Turn `bin/ubuntu-setup.sh` into a setup script that configures a fresh
	ubuntu box into a server for your new app.  Just make a few needed changes
	in various places marked by "TODO"s.

5) Edit `.env` to reflect your project's name and your domain name.  There
	are three versions of your domain name: 
    1. your actual domain name, which should resolve to your production server;
    2. your development domain name, which should be like your production
	   domain name, but with the TLD changed to `dev` (e.g. example.com ->
       example.dev); and
    3. your staging domain name, which should be a subdomain of your production
	   domain name, e.g. staging.example.com.

6) Now that you've done the steps in this README you can get rid of it.
	Replace it with another README that will be used by developers to get
	started on your project:

	$ mv README.new.md README.md

	Go ahead and follow the steps in that README.

