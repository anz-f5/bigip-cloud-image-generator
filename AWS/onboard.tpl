#!/bin/bash

tmsh modify sys db config.allow.rfc3927 value enable

tmsh modify /auth password-policy policy-enforcement disabled
tmsh modify /auth user admin password admin

tmsh modify sys db provision.extramb value 1000
tmsh modify sys db restjavad.useextramb value true

tmsh save sys config

bigstart restart restjavad restnoded