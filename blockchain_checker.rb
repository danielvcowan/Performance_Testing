# frozen_string_literal: true

require 'flamegraph'

# Verifies a given blcokchain
class BlockchainChecker
  attr_reader :file, :previous_block_num, :previous_hash, :previous_time, :addr_table

  def initialize(file_name)
    @file = File.open(file_name)
    @previous_block_num = '-1'
    @previous_hash = '0'
    @previous_time = '-1.-1'
    @addr_table = Hash.new(0)
    @dictionary = {}
  end

  def main
    line_num = 0
    @file.each do |line|
      blk_num, old_hash, trans, time, block_hash, block_arr = parse_block(line, line_num)
      return false unless blk_num

      new_hash = calculate_hash(block_arr)
      return false unless do_transactions(trans, line_num)

      return false unless check_block(blk_num, old_hash, trans, time, new_hash, block_hash.chomp, line_num)

      update_previous_values(blk_num, new_hash, time)
      line_num += 1
    end
    @file.close
    print_addresses
  end

  def parse_block(line, line_num)
    begin
      temp_arr = line.split('|')
      raise StandardError if temp_arr.size != 5

      block_arr = (line[0...line.rindex('|')]).unpack('U*')
    rescue StandardError
      puts "Line #{line_num}: Could not parse line '#{line}'"
      return false
    end
    temp_arr << block_arr
  end

  def update_previous_values(blk_num, new_hash, time)
    @previous_block_num = blk_num
    @previous_hash = new_hash
    @previous_time = time
  end

  def check_block(blk_num, old_hash, _trans, time, new_hash, block_hash, line)
    unless blk_num.to_i == (@previous_block_num.to_i + 1)
      error_cases(line, 1, blk_num, @previous_block_num.to_i + 1)
      return false
    end
    if old_hash != @previous_hash
      error_cases(line, 2, old_hash, @previous_hash)
      return false
    end
    if new_hash != block_hash
      error_cases(line, 3, block_hash, new_hash)
      return false
    end
    unless check_time(time)
      error_cases(line, 4, time, @previous_time)
      return false
    end
    check_addresses(line)
  end

  def check_time(time)
    begin
      seconds, nano = time.split('.')
      old_seconds, old_nano = @previous_time.split('.')
    rescue StandardError
      return false
    end
    return true if seconds.to_i > old_seconds.to_i

    return false if seconds.to_i < old_seconds.to_i

    return false if nano.nil?

    nano.to_i > old_nano.to_i
  end

  def check_addresses(line)
    @addr_table.each do |key, value|
      if value.negative?
        error_cases(line, 5, value, key)
        return false
      end
    end
    true
  end

  def do_transactions(trans, line)
    begin
      trans_table = trans.split(':')
      trans_table.each do |transaction|
        sender, reciever = transaction.split('>')
        amt = reciever[(reciever.rindex('(') + 1)...reciever.rindex(')')].to_i
        reciever = reciever[0...reciever.rindex('(')]
        if sender.length != 6 || reciever.length != 6
          error_cases(line, 6, sender, reciever)
          return false
        end
        @addr_table[sender] = @addr_table[sender] - amt if sender != 'SYSTEM'
        @addr_table[reciever] = @addr_table[reciever] + amt
      end
    rescue StandardError
      puts "Line #{line}: Could not parse transaction list '#{trans}'"
      return false
    end
    true
  end

  def calculate_hash(block)
    sum = 0
    until block.empty?
      multiplier = block.count(block[0])
      sum += (multiplier * hash(block[0]))
      block.delete(block[0])
    end
    sum = sum % 65_536
    sum.to_s(16)
  end

  def hash(x)
    val = @dictionary.fetch(x, nil)
    if !val.nil?
      return val
    else
      @dictionary[x] = ((x**3000) + (x**x) - (3**x)) * (7**x)
      return @dictionary[x]
    end
  end

  def print_addresses
    @addr_table.sort.map do |key, value|
      puts "#{key}: #{value} billcoins" if value.positive?
    end
  end

  def error_cases(line, error_num, value, expected)
    case error_num
    when 0
      puts "Usage: ruby verifier.rb <name_of_file>\nname_of_file = name of file to verify"
    when 1
      puts "Line #{line}: Invalid block number #{value}, should be #{expected}"
    when 2
      puts "Line #{line}: Previous hash was #{value}, should be #{expected}"
    when 3
      puts "Line #{line}: Current hash is #{value}, should be #{expected}"
    when 4
      puts "Line #{line}: New timestamp #{value} <= previous #{expected}"
    when 5
      puts "Line #{line}: Address #{expected} has invalid balance of #{value}"
    when 6
      puts "Line #{line}: Address " + (value.length != 6 ? value.to_s : expected.to_s) + ' is not six digits'
    end
    puts 'BLOCKCHAIN INVALID'
    @file&.close
  end
end
