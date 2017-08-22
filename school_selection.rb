require 'sinatra'
require 'bundler'
require 'active_record'
require 'net/http'
require 'awesome_print'
require 'json'

class SelectionApp < Sinatra::Application

  class School
    attr_accessor :district, :code, :name, :type, :students, :score

    def initialize(school_json, district)
      @district = district
      @code = school_json['code']
      @name = school_json['name']
      @type = school_json['type']
      @students = school_json['students']
      @score = school_json['score']
    end
  end

  class Data
    attr_accessor :self_data, :selections_data

    def initialize
      @self_data = data_pull('http://challenge.brightbytes.net/api/v1/districts/self')
      @selections_data = data_pull('http://challenge.brightbytes.net/api/v1/districts/selections')
    end

    def data_pull(uri)
      url = URI.parse(uri)
      req = Net::HTTP::Get.new(url.to_s)
      req['X-Auth-Token'] = '1fee3b4e-d99d-404c-832b-b023116d318a'
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.request(req)
      }
      JSON.parse(res.body)
    end

    def aggregate_selections_schools
      schools = []
      selections_data['data']['districts'].each do |school|
        schools << school
      end
      schools
    end

    def find_average_students
      students_by_district = {}
      $data.selections_data['data']['district'].each do |d|
        $data.aggregate_selections_schools.each do |s|
          students << s['students']
        end
        sum = students.inject(:+)
        items = students.count
        students_by_district[d['name']] = sum/items
      end
    end

    def self_avg_students
      $data.aggregate_selections_schools.each do |s|
        students << s['students']
      end
      sum = students.inject(:+)
      items = students.count
      sum/items
    end

    def find_match
      
    end

    def aggregate_self_schools
      schools = []
      $data.self_data['data']['district']['schools'].each do |school|
        schools << school
      end
    end

    def self_district
      $data.self_data['data']['district']['name']
    end


  end




  $data = Data.new
end

get '/' do
  @district = $data.self_district
  @self_schools = $data.aggregate_self_schools
  @selections_schools = $data.aggregate_selections_schools
  erb :index
end

post '/' do
  redirect '/result'
end

get '/result' do
  @district = $data.self_district
  @match = #method to find match
  erb :result
end

get '/selections_data.json' do
  content_type :json
  $data.selections_data.to_json
end

get '/self_data.json' do
  content_type :json
  $data.self_data.to_json
end
