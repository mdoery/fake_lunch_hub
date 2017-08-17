Jason Swett has a nice tutorial to run AngularJS on Rails:
http://angularonrails.wpengine.com/wire-ruby-rails-angularjs-single-page-application-updated-2016/

However, his environment is not fully specified, so in following the tutorial in my local dev environment, I got quite a few non-trivial errors. The biggest problem occurred when a fairly recent version of Ruby and Rails got installed, and those did not work well with the tutorial. I had a lot of trouble getting rid of them. I tried not to repeat these mistakes on my AWS instance, but I ran into the same problem there.

The following is what I did to get the demo up and running on an AWS instance using Ubuntu 14.04. This tutorial assumes you've got your AWS instance set up, and that you can ssh into it. I ssh'd in as the user "ubuntu", which has root permissions.

First, install rvm. This is the Ruby Version Manager, which allows you to switch between different versions of Ruby. If you do not use the correct version of ruby and various gems, you will run into problems:

```
sudo apt-add-repository -y ppa:rael-gc/rvm
sudo apt-get update
sudo apt-get install rvm
```

Next, switch to ruby 2.2.6, which seems to be correct for the tutorial.

```
rvm 2.2.6
```

When you do this, you see these instructions in the output:

```
* First you need to add all users that will be using rvm to 'rvm' group,
  and logout - login again, anyone using rvm will be operating with `umask u=rwx,g=rwx,o=rx`.

* To start using RVM you need to run `source /etc/profile.d/rvm.sh`
  in all your open shell windows, in rare cases you need to reopen all shell windows.
```

Follow those instructions:

```
sudo usermod -a -G rvm ubuntu
```

Then log out, log back in again, then do:

```
source /etc/profile.d/rvm.sh
```

Make a directory called ```Projects/angularonrails/``` and go into it:

```
cd Projects/angularonrails/

rvm -v
# Output is:
# rvm 1.29.2 (manual) by Michal Papis, Piotr Kuczynski, Wayne E. Seguin [https://rvm.io/]
```

Next install a specific version of Ruby and Rails:

```
rvm install ruby-2.2.6
# check, works!

gem install rails -v 4.2.5.1
# check! Takes a while. Go read something.
# ...
# ... 354 seconds
# 33 gems installed
```

Now, use rvm to create a specific environment where chosen versions of gems will be used: https://rvm.io/gemsets/basics


```
rvm gemset create rails4251

rvm 2.2.6@rails4251 ; rails --version
# Oops! Output:
# /usr/share/rvm/rubies/ruby-2.2.6/lib/ruby/site_ruby/2.2.0/rubygems.rb:271:in `find_spec_for_exe': can't find gem railties (>= 0.a) (Gem::GemNotFoundException)

rvm 2.2.6@rails4251
# Output:
# Using /home/ubuntu/.rvm/gems/ruby-2.2.6 with gemset rails4251

# At this point, I did 'gem install railties'.
# This may have been a mistake; I probably should have done 'gem install railties -v 4.2.5.1'.
# After running 'gem install railties', I wound up with Rails 5.1.3, which is incompatible
# in numerous ways with the tutorial. I had to run numerous uninstall commands to get rid of 
# versions 5.1.3 of various gems, like 'gem uninstall railties -v 5.1.3' etc.

gem install railties -v 4.2.5.1

rails -v
# Output:
# Expected string default value for '--rc'; got false (boolean)
# Rails 4.2.5.1
# Yes! If you get Rails 5.1.3, you will have to do some work to figure out how to remove it
# until your environment is using 4.2.5.1
```


Prepare for the next part of the tutorial by installing postgres and dev version for headers:

```
sudo apt-get install postgresql
sudo apt-get install libpq-dev
# Create postgres superuser who can create databases (note, I am logged in as user "ubuntu"):
sudo -u postgres createuser --superuser ubuntu
# Output:
# CREATE ROLE fake_lunch_hub PASSWORD 'md574f0402c020a3a086b0a0b891fa15891' SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN;
gem install rails-api
```


Next Jason says:

```
rails-api new fake_lunch_hub -T -d postgresql
cd fake_lunch_hub
rake db:create
```

The rake command bombed for me. I had to make sure all 5.1.3 versions were removed from my gems. I used this command to look for them:

```
ruby -S gem list --local
```

I noticed there were several gems with 5.1.3, and I think they got installed because the Gemfile for fake_lunch_hub points to 5.1.3 or higher. I edited my Gemfile to use 4.2.51:

```
source 'https://rubygems.org'


gem 'rails', '4.2.5.1'

gem 'rails-api', '0.4.1'

gem 'spring', :group => :development


gem 'pg'
```

I had gone through the same problems in my local environment before trying this on an AWS instance, so in the end I was able to copy my local version of Gemfile.lock over to the instance, and run "bundle install" in the dir where my Gemfile.lock was. 

Then I could run "rails -v" and it gave the same output as on my development machine:

```
ubuntu@ip-172-31-24-140:~/Projects/angularonrails/fake_lunch_hub$ rails -v
# Output:
# Expected string default value for '--rc'; got false (boolean)
# Rails 4.2.5.1
```

Once I installed the gems using my new Gemfile info, I then backed out of the fake_lunch_hub dir, deleted it, and reran the rails-api setup line:

```
rails-api new fake_lunch_hub -T -d postgresql
cd fake_lunch_hub/
rake db:create
```

That worked, and from then on I didn't have many problems.

Next, Jason says "Add gem 'rspec-rails' to your Gemfile (in the test group)". He means to edit your Gemfile, adding these lines:

```
group :test do
  gem 'rspec-rails'
end
```

You can see the final version of my Gemfile here: https://github.com/mdoery/fake_lunch_hub/blob/master/Gemfile


Then run:

```
bundle install
rails g rspec:install
```


Next, edit config/application.rb as instructed.

Then:

```
rails g scaffold group name:string
```

Next, edit db/migrate/20170816220808_create_groups.rb (the timestamp that is part of your file's name will be different, but the file will be in the db/migrate dir). Add the lines as instructed.

Then:

```
rake db:migrate
```

Edit these files as instructed:

```
vi spec/models/group_spec.rb
vi app/models/group.rb
vi spec/controllers/groups_controller_spec.rb
```

Then run rspec, see passing tests:

```
rspec
# Output:
# ...
# 16 examples, 0 failures, 15 pending
```

Next:

```
npm install -g yo

npm install -g generator-gulp-angular

mkdir client && cd $_

yo gulp-angular fake_lunch_hub
# Note: When running yo, everything I did was the same as Jason's advice, except that I had a choice for JS preprocessor - there were two options with ES6, and I went with ES6 Babel. I'm not sure if this was correct.
```

These commands are missing in his instructions:

```
npm install -g bower
npm install gulp-cli -g
npm install gulp -D
touch gulpfile.js
bower install
```

At this point he tells you to do "gulp serve" but skip it unless you want to test if it is working.

Next, edit this file as instructed -

```
vi gulp/server.js
```

Add middleware so that Rails communicates with Angular - 

```
npm install --save-dev http-proxy-middleware
```

Edit as instructed:

```
vi ../db/seeds.rb
cd ..
rake db:seed
# You may get warnings from Postgres, but no errors
cd client
```

Edit as instructed:

```
vi src/app/index.route.js
```

Create new files and edit as instructed:

```
vi src/app/components/groups.controller.js
vi src/app/components/groups.jade
```

Then run:

```
bower install --save angularjs-rails-resource
```

Edit as instructed:

```
src/app/index.module.js
vi src/app/components/groups.controller.js
```

NOTE! In the last section, the tutorial says to edit src/app/views/groups.jade. This is incorrect; edit the same jade file as before:

```
vi src/app/components/groups.jade
```

Finally you should be done! Run this:

```
gulp serve:full-stack
# I saw an error message here -
# Module build failed: Error: Plugin 20 specified in "/home/ubuntu/Projects/angularonrails/fake_lunch_hub/client/node_modules/babel-preset-es2015/index.js" provided an invalid property of "name"
# ...
# However, the application ran. So far, I haven't investigated further.
```

Currently the demo is running here: http://ec2-54-86-19-3.compute-1.amazonaws.com:3001/#/groups

Here's a link to a screenshot of what you should see: https://github.com/mdoery/fake_lunch_hub/blob/master/aws-groups.png