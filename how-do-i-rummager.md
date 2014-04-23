# Rummager

Based on a cluster of ElasticSearch, index is split across nodes

You have indexes, the equivalent of having a database

GDS have mainstream and insidegov indexes - we'll probably need one for ODI
and Dapaas

An ElasticSearch index is a bucket for a collection of documents. Imagine a dump
of JSON. What that looks like is defined in rummager as a YAML file (
[elasticsearch_schema.yml](https://github.com/alphagov/rummager/blob/master/elasticsearch_schema.yml))

Also a synonyms file, a blacklist and some other customisable things.

## How does this stuff get into Rummager

On save, if the artefact is live and has indexable content, it makes a post
or a put via the rummagable gem directly to ElasticSearch.

When a post is made live in Publisher, it posts to Panopticon, which in turn posts
to ElasticSearch.

Deciding what to send is defined in the models as `indexable_content`.

When an artefact is deleted, it will also be deleted from Rummager.

## Rebuilding indexes

Any time you change something in the schema, you need to migrate an index.

This takes some time, so there's Sidekiq, queuing and worker stuff. Lives
in Rummager. Gets stuff out of the index and puts it in a new one.

# Searching

Goes from frontend > content API > Rummager > Elasticsearch

Depending on the settings, some words (like 'and' etc) may get dropped or changed

This then queries against the particular fields that have been put into Elasticsearch
as a blob of text

Elasticsearch does some magic to check the relevancy of a document. Rummager also
boosts relevancy by edition type in the rules. DON'T RELY ON THIS THOUGH - search
should be organic.

If the thing you are searching for is in the title it's also seen as more relevant.

Rummager also breaks down searches and re-searches with missing words.

You can brute force the thing at the top. USE THIS SPARINGLY - it slows everything
down massively.

Rummager also uses aspell to return spelling suggestions if there are no results.

![][1]
![][2]


  [1]: https://lh5.googleusercontent.com/-zyIX52UU6dE/U1fCq9VC7DI/AAAAAAAAACk/1oXb27Y1K-k/s500/2014-04-23%25252012.07.11.jpg "2014-04-23 12.07.11.jpg"
  [2]: https://lh5.googleusercontent.com/-BgfhMy6uQyo/U1fCvFvJhZI/AAAAAAAAACs/FiO8kWisBfI/s500/2014-04-23%25252012.06.56.jpg "2014-04-23 12.06.56.jpg"
