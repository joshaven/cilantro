# Introduction
This is the official continuation of Cilantro, a fork from http://github.com/dcparker/cilantro.

The original author is no longer working on this project.  Until further notice, all updates will be managed by myself.  

If you have any questions, comments or concerns send them to yourtech@gmail.com


# Notice
I am currently working on the 'gem' branch which is in the testing stage and will soon be 
released as a gem.  If you are interested in working on the current code base, checkout the 
gem branch and run the following
Then make a project... something like:

    cd ~/src
    git clone http://github.com/joshaven/cilantro.git
    cd cilantro
    git checkout gem
    rake build
    sudo gem install pkg/cilantro-*.gem
    cd ~/projects
    mkdir my_cool_cilantro_app
    cd my_cool_cilantro_app
    cilantro generate
    # To start developing edit the project files:
    mate .
    # OR, To run the sample app: type 'cilantro' and then browse to your localhost on port 5000
    cilantro
