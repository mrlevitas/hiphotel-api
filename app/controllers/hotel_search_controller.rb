require 'open-uri'
require 'json'

PROVIDERS = ['expedia', 'orbitz', 'priceline', 'travelocity', 'hilton']

class HotelSearchController < ApplicationController

  def index
    json_results = []
    threads = []
    request_uri = 'http://localhost:9000/scrapers/'

    endpoints = PROVIDERS.map { |e| request_uri + e  }

    endpoints.each do |url|
      threads << Thread.new do
          json_results << JSON.parse( open(URI.parse(url)).read )['results']
      end
    end
    threads.each { |t| t.join }

    merged_arr = merge_sorted_arrays(json_results)

    render json: ( { results: merged_arr } ).to_json
  end

  private

  def merge_sorted_arrays(lists)
    result_arr = []

    k = lists.size

    if k == 1
      return lists[0]
    elsif k == 2
      merge_2_lists( lists.first , lists.last )
    else
      half_point = k / 2

      half_point = (k.odd?) ? half_point : half_point - 1

      first_half = merge_sorted_arrays lists[0..half_point]
      second_half = merge_sorted_arrays lists[(half_point + 1)..(k - 1)]
      result_arr = merge_2_lists first_half , second_half
    end
    result_arr
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
