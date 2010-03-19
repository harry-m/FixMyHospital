require 'rubygems'
require 'hpricot'
Hpricot.buffer_size = 262144
require 'open-uri'
require 'enumerator'
require 'active_support'
require 'cgi'

class NHSService
  include Enumerable

  # Service types
  GP = 1
  DENTIST = 2
  PHARMACIST = 3 
  OPTICIAN = 4
  HOSPITAL = 5
  WALKIN = 7
  STOP_SMOKING = 9
  NHS_TRUST = 10
  SEXUAL_HEALTH = 11
  MATERNITY = 12
  SPORT_FITNESS = 13
  PARENTING_CHILDCARE = 15
  ALCOHOL = 17
  FOR_CARERS = 19
  RENAL = 20
  MINOR_INJURIES = 21
  MENTAL_HEALTH = 22
  BREAST_CANCER = 23
  INDEPENDENT_LIVING = 24
  MEMORY_PROBLEMS = 26
  ABORTION = 27
  FOOT = 28
  DIABETES = 29
  ASTHMA = 30
  MIDWIFERY = 31
  COMMUNITY_CLINICS =32

  attr_reader :service_type, :postcode
  def initialize(q)
    @service_type = HOSPITAL
    @values = []

    uri = "http://www.nhs.uk/NHSCWS/Services/ServicesSearch.aspx?user=#{nhs_api[:username]}&pwd=#{nhs_api[:password]}&q=#{CGI::escape(q)}&type=#{service_type}&PageNumber=1&pageSize=45"

    puts "Requesting #{uri}..."

    doc = Hpricot(open(uri))
    
    doc.search("//service").each do |el|
      item = new_item(el)
      @values.push item
    end
  end

  def each(&block)
    @values.each do |item|
      yield item
    end

    @values
  end

  def all
    rv = []
    each{|d| rv.push d }
    rv
  end

  def nhs_api
    self.class.nhs_api
  end

  def self.nhs_api
    @nhs_api ||= if ENV["nhs_password"] and ENV["nhs_username"]
      {:username => ENV["nhs_username"], :password => ENV["nhs_password"]}
    else
      YAML.load(File.open("config/nhs_api.yml")).symbolize_keys
    end
  end
end
