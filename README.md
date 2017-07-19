# Rearmed Rails
<a href='https://ko-fi.com/A5071NK' target='_blank'><img height='32' style='border:0px;height:32px;' src='https://az743702.vo.msecnd.net/cdn/kofi1.png?v=a' border='0' alt='Buy Me a Coffee' /></a> 

A collection of helpful methods and monkey patches for Rails

The difference between this library and others is that all monkey patching is performed in an opt-in way because you shouldnt be using methods you dont know about anyways. 

```ruby
# Gemfile

gem 'rearmed_rails'
```

Run `rails g rearmed_rails:setup` to create a settings files in `config/initializers/rearmed_rails.rb` where you can opt-in to the monkey patches available in the library. Set these values to true if you want to enable the applicable monkey patch.

```ruby
# config/initializers/rearmed.rb

RearmedRails.enabled_patches = {
  rails: {
    active_record: {
      find_duplicates: false,
      find_in_relation_batches: false,
      find_or_create: false,
      find_relation_each: false,
      newest: false,
      or: false,
      pluck_to_hash: false,
      pluck_to_struct: false,
      reset_auto_increment: false,
      reset_table: false
    },
    helpers: {
      field_is_array: false,
      link_to_confirm: false,
      options_for_select_include_blank: false,
      options_from_collection_for_select_include_blank: false
    },
    v3: {
      all: false,
      pluck: false,
      update_columns: false
    }
  },
  minitest: {
    assert_changed: false,
    assert_not_changed: false
  }
}


require 'rearmed_rails/apply_patches'
```


## Rails

### ActiveRecord

```ruby
# This version of `or` behaves way nicer than the stupid one that was implemented in Rails 5
# it allows you to do what you need when you want to. This patch is for Rails 4, 5+ 
Post.where(name: 'foo').or.where(content: 'bar')
Post.where(name: 'foo').or.my_custom_scope
Post.where(name: 'foo').or(Post.where(content: 'bar'))
Post.where(name: 'foo').or(content: 'bar')

Post.pluck_to_hash(:name, :category, :id)
Post.pluck_to_struct(:name, :category, :id)

Post.find_or_create(name: 'foo', content: 'bar') # use this instead of the super confusing first_or_create method
Post.find_or_create!(name: 'foo', content: 'bar')

Post.find_duplicates # return active record relation of all records that have duplicates. By default it skips the primary_key, created_at, updated_at, & deleted_at columns
Post.find_duplicates(:name) # find duplicates based on the name attribute
Post.find_duplicates(:name, :category) # find duplicates based on the name & category attribute
Post.find_duplicates(self.column_names.reject{|x| ['id','created_at','updated_at','deleted_at'].include?(x)})

# It also can delete duplicates. Valid values for keep are :first & :last. Valid values for delete_method are :destroy & :delete. soft_delete is only used if you are using acts_as_paranoid on your model.
Post.find_duplicates(:name, :category, delete: true)
Post.find_duplicates(:name, :category, delete: {keep: :first, delete_method: :destroy, soft_delete: true}) # these are the default settings for delete: true

Post.newest # get the newest post, by default ordered by :created_at
Post.newest(:updated_at) # different sort order
Post.newest(:published_at, :created_at) # multiple columns to sort on

Post.reset_table # delete all records from table and reset autoincrement column (id), works with mysql/mariadb/postgresql/sqlite
# or with options
Post.reset_table(delete_method: :destroy) # to ensure all callbacks are fired

Post.reset_auto_increment # reset mysql/mariadb/postgresql/sqlite auto-increment column, if contains records then defaults to starting from next available number
# or with options
Post.reset_auto_increment(value: 1, column: :id) # column option is only relevant for postgresql

Post.find_in_relation_batches # this returns a relation instead of an array
Post.find_relation_each # this returns a relation instead of an array
```

Note: All methods which involve deletion are compatible with Paranoia & ActsAsParanoid

### Helpers

```ruby
# field_is_array: works with field type tag, form_for, simple form, etc
= text_field_tag :name, is_array: true #=> <input type='text' name='name[]' />

# options_for_select_include_blank
options_for_select(@users.map{|x| [x.name, x.id]}, include_blank: true, selected: params[:user_id])

# options_from_collection_for_select_include_blank
options_from_collection_for_select(@users, 'id', 'name', include_blank: true, selected: params[:user_id])

# returns to rails 3 behaviour of allowing confirm attribute as well as data-confirm
= link_to 'Delete', post_path(post), method: :delete, confirm: "Are you sure you want to delete this post?" 
```

### Rails 3.x Backports
```ruby
Post.all # Now returns AR relation
Post.first.update_columns(a: 'foo', b: 'bar')
Post.pluck(:name, :id) # adds multi column pluck support ex. => [['first', 1], ['second', 2], ['third', 3]]
```

### Minitest Methods
```ruby
assert_changed 'user.name' do
  user.name = "Bob"
end

assert_not_changed -> { user.name } do
  user.update(user_params)
end

assert_not_changed lambda{ user.name } do
  user.update(user_params)
end
```

# Contributing
If you want to request a new method please raise an issue and we will discuss the idea. 


# Credits
Created by Weston Ganger - [@westonganger](https://github.com/westonganger)

For any consulting or contract work please contact me via my company website: [Solid Foundation Web Development](https://solidfoundationwebdev.com)

## Similar Libraries Created By Me
- [Rearmed Ruby](https://github.com/westonganger/rearmed-rb)
- [Rearmed JS](https://github.com/westonganger/rearmed_rails)
- [Rearmed CSS](https://github.com/westonganger/rearmed_css)
