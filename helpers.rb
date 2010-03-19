helpers do
  def hospital_class(hospital)
    @count ||= 0
    classes = ''

    if(@count == 0 || @count % 3 == 0)
      classes += ' clear'
    end

    if(@count % 2 == 0)
      classes += ' even'
    else
      classes += ' odd'
    end

    classes += " col_#{@count % 3}"

    @count += 1

    classes
  end

  def comment_class(comment)
    @comment_count ||= 0
    classes = ''

    if(@comment_count % 2 == 0)
      classes += ' even'
    else
      classes += ' odd'
    end

    @comment_count += 1

    classes
  end

  def get_services(q)
    hospitals = nil
    cache_file = "./cache/find_#{q.gsub(/\W/, '_').downcase}.yaml"

    if File.exists?(cache_file)
      hospitals = YAML::load(File.read(cache_file))
      puts "# Results for '#{q}' retrieved from cache: #{cache_file}"
    else
      puts "# Fetching results for '#{q}'"
      hospitals = NHSHospitals.new(q)
      
      File.open(cache_file, 'w') do |out|
        YAML::dump(hospitals, out)
      end
    end

    hospitals
  end

  def get_service(code1, code2)
    cache_file = "./cache/service_#{code1}_#{code2}"
    YAML::load(File.open(cache_file).read())
  end
end
