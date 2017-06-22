require 'open-uri'
require 'json'

PROVIDERS = ['expedia', 'orbitz', 'priceline', 'travelocity', 'hilton']

class HotelSearchController < ApplicationController

  def index
    json_results = []
    request_uri = 'http://localhost:9000/scrapers/'

    endpoints = PROVIDERS.map { |e| request_uri + e  }

    endpoints.each do |url|
      json_results << JSON.parse( open(url).read )['results']
    end

    merged_arr = merge_sorted_arrays(json_results)

    render json: ( { results: merged_arr } ).to_json
  end

  private

  def merge_sorted_arrays(lists)
    result_arr = []
    while !lists.empty? do

      top = lists.inject do |candidate, other|
        candidate.first['ecstasy'] > other.first['ecstasy'] ? candidate : other
      end

      result_arr << top.shift

      lists = lists.reject(&:empty?)
    end
    result_arr
  end
end
