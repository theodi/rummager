# This file can be overwritten on deployment

set :enable_queue, ! ENV["QUIRKAFLEEG_RUMMAGER_ENABLE_QUEUE"].nil?
