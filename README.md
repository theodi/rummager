# Rummager

Rummager is now primarily based on elasticsearch.  

## Get started

Install [elasticsearch 0.20](http://www.elasticsearch.org/downloads/0-20-6/).
Rummager doesn't work with 0.90.

Run the application with `./startup.sh` this uses shotgun/thin.

To create indices, or to update them to the latest index settings, run:

    RUMMAGER_INDEX=all bundle exec rake rummager:migrate_index

Rummager has an asynchronous mode, disabled in development by default, that
posts documents to a queue to be indexed later by a worker. To run this in
development, you need to run both of these commands:

    ENABLE_QUEUE=1 ./startup.sh
    bundle exec rake jobs:work

## Indexing content

You will need Panopticon and Rummager running.

To build an index from scratch you will need to be in Publisher repo and run:

  bundle exec rake panopticon:register

This will loop through each published edition and create a RegisterableEdition which will call Panopticon to update it's artefact with.

Remember: the on save observer in panopticon is what fires off the submit to Elasticsearch.

By default, Panopticon will not try to index search content in development mode, so you'll need to have an extra environment variable to it.

  UPDATE_SEARCH=1


## Adding a new index

To add a new index to Rummager, you'll first need to add it to the list of index names Rummager knows about in [`elasticsearch.yml`](elasticsearch.yml). For instance, you might change it to:

    index_names: ["dapaas", "odi", "my_new_index"]

To create the index, you'll need to run:

    RUMMAGER_INDEX=my_new_index bundle exec rake rummager:migrate_index

This task will fail if you've already created an index with this name, as
Rummager can't add an alias that is the name of an existing index. In this case,
you'll either need to delete your existing index or, if you want to keep its
contents, run:

    RUMMAGER_INDEX=my_new_index bundle exec rake rummager:migrate_from_unaliased_index


## Once ODI search is LIVE

The below Health check will need updating with relevant data for ODI and then you can have some "objective" metrics for search.

## Health check

As we work on rummager we want some objective metrics of the performance of search. That's what the health check is for.

To run it first download the healthcheck data:

$ ./bin/health_check -d

Then run against your chosen indices:

$ ./bin/health_check government mainstream

By default it will run against the local search instance. You can run against a remote search service using the --json or --html options.
