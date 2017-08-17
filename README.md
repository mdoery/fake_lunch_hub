== README

Jason Swett has a nice tutorial to run AngularJS on Rails:
http://angularonrails.wpengine.com/wire-ruby-rails-angularjs-single-page-application-updated-2016/

However, his environment is not fully specified, so in following the tutorial,
I got quite a few non-trivial errors.

This is what I did to get his demo up and running on an AWS instance running Ubuntu 14.04:

### Install rvm ###

rvm is the Ruby Version Manager, which allows you to switch between different versions of Ruby:

```
sudo apt-add-repository -y ppa:rael-gc/rvm
sudo apt-get update
sudo apt-get install rvm
```

### Switch to ruby 2.2.6 ###

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



