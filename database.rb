DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'mysql://localhost/fixmyhospital')

class Problem
  include DataMapper::Resource

  property :id,         Serial
  property :code1,      Text
  property :code2,      Text
  property :subject,    Text
  property :details,    Text
  property :photo,      Text
  property :name,       Text
  property :email,      Text
  property :phone,      Text
  property :fixed,      Boolean, :default => false
  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :comments
end

class Comment
  include DataMapper::Resource

  property :id,         Serial
  property :problem_id, Integer
  property :name,       Text
  property :email,      Text
  property :web,        Text
  property :comment,    Text
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :problem
end

#DataMapper.auto_migrate!
#p = Problem.new(:code1 => 'RKEQ4', :subject => 'Things broke!', :details => 'Srsly, they were important.')
#p.save!
