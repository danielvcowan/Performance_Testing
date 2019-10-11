# frozen_string_literal: true

require_relative 'blockchain_checker'
require 'benchmark'

def check_arguments(argv)
  return false if argv.size > 1 || argv.empty?

  return false unless File.exist?(argv[0])

  true
end

Flamegraph.generate('verify.html') do
  if check_arguments(ARGV)
    checker = BlockchainChecker.new(ARGV[0])
    checker.main
  else
    puts "Usage: ruby verifier.rb <name_of_file>\nname_of_file = name of file to verify"
  end
end
