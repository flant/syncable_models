# SyncableModels [![Build Status](https://travis-ci.org/flant/syncable_models.svg?branch=master)](https://travis-ci.org/flant/syncable_models) [![Gem Version](https://badge.fury.io/rb/syncable_models.svg)](https://badge.fury.io/rb/syncable_models)

This gem helps you to:

1. Fetch object attributes from the outside of your app
2. Mark objects as synced by a special tag
3. Drop this marks automatically when the object updates

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'syncable_models'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install syncable_models

Then generate and run migration for Sync model:

    $ rails syncable_models:install:migrations
    $ rake db:migrate

## Usage

At first you should mark you model as syncable:

```ruby
class Project < ApplicationRecord
  include SyncableModels::ActiveRecord
  ...
end
```

Then create a controller with API methods.

```ruby
class ImportApiController < ApplicationController
  include SyncableModels::Controller
  sync_for :projects
end
```

This code will automatically generate two api methods for this controller:

1. `projects` - get a list of non-synced Project objects
  * receives: destination argument - the tag for syncing and an optional count parameter (default value is 50).
  * returns: response with an array of the objects, non-synced by this tag
2. `sync_projects` - sync Project objects by a tag
  * receives: ids - an array of objects' ids for syncing; destination - tag for syncing
  * returns: {status: 200} if everything is Ok.

Example:
```
http://host.dev/import_api/projects?destination=redmine&count=50
http://host.dev/import_api/sync_projects?ids[]=c4bebd13-7de4-450d-82d7-e9a575f978c7&destination=redmine
```
