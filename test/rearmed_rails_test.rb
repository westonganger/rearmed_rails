#!/usr/bin/env ruby -w

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'yaml'
require 'minitest'
require 'minitest/autorun'

require 'active_record'
require 'action_view'
require 'rearmed_rails'

RearmedRails.enabled_patches = :all
RearmedRails.apply_patches!

class RearmedRailsTest < MiniTest::Test
  def setup
  end

  def teardown
  end

  def test_enabled_patches
    RearmedRails.instance_variable_set(:@applied, false)

    default = RearmedRails.const_get(:DEFAULT_PATCHES)

    RearmedRails.enabled_patches = nil
    assert_equal RearmedRails.enabled_patches, default

    RearmedRails.enabled_patches = {}
    assert_equal RearmedRails.enabled_patches, default

    RearmedRails.enabled_patches = :all
    assert_equal RearmedRails.enabled_patches, :all

    RearmedRails.enabled_patches = {active_record: true, helpers: false, foo: :bar}
    assert_equal RearmedRails.enabled_patches, default.merge({active_record: true})

    [true, false, [], '', 1, :foo, RearmedRails].each do |x|
      assert_raises TypeError do
        RearmedRails.enabled_patches = x
      end

      if x != true && x != false
        assert_raises TypeError do
          RearmedRails.enabled_patches = {active_record: x}
        end
      end
    end
  end

  def test_general_rails
    #Post.pluck_to_hash(:name, :category, :id)
    #Post.pluck_to_struct(:name, :category, :id)

    #Post.find_or_create(name: 'foo', content: 'bar') # use this instead of the super confusing first_or_create method
    #Post.find_or_create!(name: 'foo', content: 'bar')

    #Post.find_duplicates # return active record relation of all records that have duplicates
    #Post.find_duplicates(:name) # find duplicates based on the name attribute
    #Post.find_duplicates([:name, :category]) # find duplicates based on the name & category attribute
    #Post.find_duplicates(name: 'A Specific Name')

    #Post.reset_table # delete all records from table and reset autoincrement column (id), works with mysql/mariadb/postgresql/sqlite
    ## or with options
    #Post.reset_table(delete_method: :destroy) # to ensure all callbacks are fired

    #Post.reset_auto_increment # reset mysql/mariadb/postgresql/sqlite auto-increment column, if contains records then defaults to starting from next available number
    ## or with options
    #Post.reset_auto_increment(value: 1, column: :id) # column option is only relevant for postgresql
  end

  def test_rails_4
    #= link_to 'Delete', post_path(post), method: :delete, confirm: "Are you sure you want to delete this post?" 
    # returns to rails 3 behaviour of allowing confirm attribute as well as data-confirm
  end

end
