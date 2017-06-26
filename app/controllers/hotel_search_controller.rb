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

    lists.each do |l|
      result_arr + l
    end

    result_arr.sort_by(&:ecstasy).reverse!
  end

  def merge_2_lists(a, b)
    result = []

    if a.empty? && b.empty?
      return []
    end

    if a.empty?
      return b
    end

    if b.empty?
      return a
    end

    result << ( a[0]['ecstasy'] > b[0]['ecstasy'] ? a.shift : b.shift )

    if a.size == 0
      return result + b
    elsif b.size ==0
      return result + a
    else
      return result + merge_2_lists(a, b)
    end

  end
end
