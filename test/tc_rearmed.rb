#!/usr/bin/env ruby -w

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'yaml'
require 'minitest'

require 'rearmed_rails'

require 'minitest/autorun'

class TestRearmedRails < MiniTest::Test
  def setup
    Minitest::Assertions.module_eval do
      alias_method :eql, :assert_equal
    end

    RearmedRails.enabled_patches = {
      rails: true,
      minitest: true
    }
    require 'rearmed_rails/apply_patches'
  end

  def test_minitest
    str = 'first'
    assert_changed "str" do
      str = 'second'
    end

    str = 'first'
    assert_changed ->{ str } do
      str = 'second'
    end

    name = 'first'
    assert_changed lambda{ name } do
      name = 'second'
    end

    name = 'first'
    assert_not_changed 'name' do
      name = 'first'
    end

    name = 'first'
    assert_not_changed ->{ name } do
      name = 'first'
    end

    name = 'first'
    assert_not_changed lambda{ name } do
      name = 'first'
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

    #Post.find_in_relation_batches # this returns a relation instead of an array
    #Post.find_relation_each # this returns a relation instead of an array
  end

  def test_rails_3
    #my_hash.compact
    #my_hash.compact!
    #Post.all # Now returns AR relation
    #Post.first.update_columns(a: 'foo', b: 'bar')
    #Post.pluck(:name, :id) # adds multi column pluck support ex. => [['first', 1], ['second', 2], ['third', 3]]
  end

  def test_rails_4
    #Post.where(name: 'foo').or.where(content: 'bar')
    #Post.where(name: 'foo').or.my_custom_scope
    #Post.where(name: 'foo').or(Post.where(content: 'bar'))
    #Post.where(name: 'foo).or(content: 'bar')

    #= link_to 'Delete', post_path(post), method: :delete, confirm: "Are you sure you want to delete this post?" 
    # returns to rails 3 behaviour of allowing confirm attribute as well as data-confirm
  end
end
