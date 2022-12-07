#!/usr/bin/env ruby

# this file is very simple and doesn't need adjustment at first glance.

require 'json'

puts JSON.generate(JSON.parse(ARGF.read), array_nl: "\n", object_nl: "\n", indent: "    ")


