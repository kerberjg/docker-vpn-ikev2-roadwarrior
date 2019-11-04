#!/bin/sh

### SETUP
/data/bin/firewall
/data/bin/networking
/data/bin/ipsec

### START
ipsec start --nofork