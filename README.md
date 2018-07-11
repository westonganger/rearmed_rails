# Rearmed Rails

<a href="https://badge.fury.io/rb/rearmed_rails" target="_blank"><img height="21" style='border:0px;height:21px;' border='0' src="https://badge.fury.io/rb/rearmed_rails.svg" alt="Gem Version"></a>
<a href='https://travis-ci.org/westonganger/rearmed_rails' target='_blank'><img height='21' style='border:0px;height:21px;' src='https://api.travis-ci.org/westonganger/rearmed_rails.svg?branch=master' border='0' alt='Build Status' /></a>
<a href='https://rubygems.org/gems/rearmed_rails' target='_blank'><img height='21' style='border:0px;height:21px;' src='https://ruby-gem-downloads-badge.herokuapp.com/rearmed?label=rubygems&type=total&total_label=downloads&color=brightgreen' border='0' alt='RubyGems Downloads' /></a>
<a href='https://ko-fi.com/A5071NK' target='_blank'><img height='22' style='border:0px;height:22px;' src='https://az743702.vo.msecnd.net/cdn/kofi1.png?v=a' border='0' alt='Buy Me a Coffee' /></a> 


A collection of helpful methods and monkey patches for Rails

The difference between this library and others is that all monkey patching is performed in an opt-in way because you shouldnt be using methods that you dont know about.

```ruby
# Gemfile

gem 'rearmed_rails'
```

Run `rails g rearmed_rails:setup` to create a settings files in `config/initializers/rearmed_rails.rb` where you can opt-in to the monkey patches available in the library. Set these values to true if you want to enable the applicable monkey patch.

```ruby
# config/initializers/rearmed.rb

RearmedRails.enabled_patches = {
    find_duplicates: false,
    find_or_create: false,
    newest: false,
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
  }
}

RearmedRails.apply_patches!
```

Some other argument formats the `enabled_patches` option accepts are:

```ruby
### Enable everything
Rearmed.enabled_patches = :all

### Disable everything
Rearmed.enabled_patches = nil

### Hash values can be boolean/nil values also
Rearmed.enabled_patches = {
  active_record: true,
  helpers: false,
}
```

By design, once `apply_patches!` is called then `RearmedRails.enabled_patches` is no longer editable and `apply_patches!` cannot be called again. If you try to do so, it will raise a `PatchesAlreadyAppliedError`. There is no-built in way of changing the patches, if you need to do so (which you shouldn't) that is up to you to figure out.


## Rails

### ActiveRecord

```ruby
Post.find_or_create(name: 'foo', content: 'bar') # use this instead of the super confusing first_or_create method
Post.find_or_create!(name: 'foo', content: 'bar')

Post.newest # get the newest post, by default ordered by :created_at
Post.newest(:updated_at) # different sort order
Post.newest(:published_at, :created_at) # multiple columns to sort on

Post.pluck_to_hash(:name, :category, :id)
Post.pluck_to_struct(:name, :category, :id)

Post.reset_table # delete all records from table and reset autoincrement column (id), works with mysql/mariadb/postgresql/sqlite
# or with options
Post.reset_table(delete_method: :destroy) # to ensure all callbacks are fired

Post.reset_auto_increment # reset mysql/mariadb/postgresql/sqlite auto-increment column, if contains records then defaults to starting from next available number
# or with options
Post.reset_auto_increment(value: 1, column: :id) # column option is only relevant for postgresql

Post.find_duplicates # return active record relation of all records that have duplicates. By default it skips the primary_key, created_at, updated_at, & deleted_at columns
Post.find_duplicates(:name) # find duplicates based on the name attribute
Post.find_duplicates(:name, :category) # find duplicates based on the name & category attribute
Post.find_duplicates(self.column_names.reject{|x| ['id','created_at','updated_at','deleted_at'].include?(x)})

# It also can delete duplicates. 
# Valid values for keep are :first & :last.
# Valid values for delete_method are :destroy & :delete. The soft-delete option is only used if you are using acts_as_paranoid on your model.
Post.find_duplicates(:name, :category, delete: true)
Post.find_duplicates(:name, :category, delete: {keep: :first, delete_method: :destroy, soft_delete: true}) # these are the default settings for delete: true
```

### Helpers

```ruby
# field_is_array: works with field type tag, form_for, simple form, etc
= text_field_tag :name, is_array: true #=> <input type='text' name='name[]' />

# options_for_select_include_blank
options_for_select(@users.map{|x| [x.name, x.id]}, include_blank: true, selected: params[:user_id])

# options_from_collection_for_select_include_blank
options_from_collection_for_select(@users, 'id', 'name', include_blank: true, selected: params[:user_id])

# returns Rails v3 behaviour of allowing confirm attribute as well as data-confirm
= link_to 'Delete', post_path(post), method: :delete, confirm: "Are you sure you want to delete this post?" 
```

# Contributing
If you want to request a new method please raise an issue and we will discuss the idea. 


# Credits
Created by [Weston Ganger](https://westonganger.com) - [@westonganger](https://github.com/westonganger)

For any consulting or contract work please contact me via my company website: [Solid Foundation Web Development](https://solidfoundationwebdev.com)

## Other Libraries in the Rearmed family of Plugins
- [Rearmed Ruby](https://github.com/westonganger/rearmed-rb)
- [Rearmed JS](https://github.com/westonganger/rearmed_rails)
- [Rearmed CSS](https://github.com/westonganger/rearmed_css)
