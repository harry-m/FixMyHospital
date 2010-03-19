require "nhs_service"
 
class NHSHospital < Struct.new(:name, :details_url, :street, :city, :region, :postcode, :code1, :code2, :email, :description)
  def initialize(*args)
    super
  end

  def inspect
    "#<NHSDoctor name=#{name.inspect}, details_url=#{details_url.inspect}, street=#{street.inspect}, city=#{city.inspect}, region=#{region.inspect}, postcode=#{postcode.inspect}, email=#{email.inspect}>"
  end
end
 
class NHSHospitals < NHSService
  def initialize(*args)
    super
    @service_type = HOSPITAL
  end

  def new_item(el)
    details_url = el.search("//providerprofilepageurl").first.inner_html
    doc = Hpricot(open(details_url.gsub(" ", "+")))
    email = doc.search("/html/body/div/form/div[2]/div[3]/div/div[2]/div[2]/dl/dd[4]/a/text()").map(&:to_s).first
    
    hospital = NHSHospital.new(
      el.search("//name").first.inner_html,
      details_url,
      el.search("//address1").first.inner_html,
      el.search("//address4").first.inner_html,
      el.search("//address5").first.inner_html,
      el.search("//postcode").first.inner_html,
      el.search("//code1").first.inner_html,
      el.search("//code2").first.inner_html,
      email,
      ''
    )

    cache_file = "./cache/service_#{hospital.code1}_#{hospital.code2}"
    File.open(cache_file, 'w') do |out|
      YAML::dump(hospital, out)
    end

    hospital
  end
end
 
