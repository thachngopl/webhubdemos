#!/bin/sh

# established 28-Aug-2013
# written by HREF Tools Corp.
# http://db.demos.href.com/webhub/seleniumgrid_linux/prepare_grid.bash

yum install java-1.7.0-openjdk

cd /usr
mkdir selenium
cd selenium

wget https://selenium.googlecode.com/files/selenium-server-standalone-2.33.0.jar

wget http://db.demos.href.com/webhub/seleniumgrid_linux/start_zombie.bash
chmod o+x start_zombie.bash

cd /usr/selenium
./start_zombie.bash 5555
