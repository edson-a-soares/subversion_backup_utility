#!/bin/bash

current_timezone="America/Fortaleza"
echo $current_timezone > /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata
