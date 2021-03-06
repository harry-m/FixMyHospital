require 'rubygems'
require 'haml'
require 'sass'
require 'sinatra'
require 'ftools'
require 'yaml'
require 'dm-core'
require 'dm-timestamps'

require 'database'
require 'helpers'
require 'nhs_hospital'

set(:haml, {:format => :html5, :attr_wrapper  => '"'})
set(:host, '0.0.0.0')

get '/' do
  haml :index
end

get '/report' do
  haml :report
end

get '/style.css' do
  headers 'Content-Type' => 'text/css; charset=utf-8'
  sass :style
end

get '/find' do
  hospitals = get_services(params[:q])

  if hospitals.size() == 1
    redirect "/view/#{hospitals.first.code1}/#{hospitals.first.code2}/#{CGI.escape(hospitals.first.name)}"
  else
    haml(:find, :locals => {:hospitals => hospitals, :search_terms => params[:q]})
  end
end

get /view\/([a-zA-Z0-9]+)\/(.*)/ do |code1, hospital_name|
  code2 = ''

  hospital = get_service(code1, code2)

  problems = Problem.all(:code1 => code1, :code2 => code2, :order => [:created_at.desc])

  haml(:view, :locals => {:hospital => hospital, :problems => problems, :params => params})
end

post '/report_problem' do
  puts "!!!!! THERE IS NO VALIDATION OR ESCAPING FOR NEW PROBLEMS OMG !!!!!"

  photo_file = ''

  if params[:photo]
    tmpfile = params[:photo][:tempfile]
    name = params[:photo][:filename]
    
    puts "Uploading file, original name #{name.inspect}"
    
    photo_file = "/photos/#{params[:code1].downcase}_#{params[:subject].gsub(/\W/, '-').downcase}_#{name.downcase}"
    while blk = tmpfile.read(65536)
      File.open('./public' + photo_file, 'a'){|w| w.write(blk)}
    end
  end

  problem = Problem.new(
    :code1 => params[:code1],
    :code2 => params[:code2],
    :subject => params[:subject],
    :details => params[:details],
    :photo => photo_file,
    :name => params[:name],
    :email => params[:email],
    :phone => params[:phone]
  )

  if problem.save
    redirect "/problem/#{problem.id}?new=true"
  else
    hospital = get_service(params[:code1], params[:code2])
    haml(:view, :locals => {:hospital => hospital, :params => params})
  end
end

get '/problem/:problem_id' do |problem_id|
  haml(:problem, :locals => {:problem => Problem.get(problem_id), :comments => Comment.all(:problem_id => problem_id), :comment_params => params, :new => params[:new]})
end

post '/post_comment' do
  puts "!!!!! THERE IS NO VALIDATION OR ESCAPING FOR NEW COMMENTS OMG !!!!!"

  comment = Comment.new(
    :problem_id => params[:problem_id],
    :comment => params[:comment],
    :name => params[:name],
    :email => params[:email],
    :web => params[:web]
  )

  if comment.save
    redirect "/problem/#{params[:problem_id]}#comment_#{comment.id}"
  else
    haml(:problem, :locals => {:problem => Problem.get(params[:problem_id]), :comments => Comment.all(:problem_id => params[:problem_id]), :comment_params => params})
  end
end
