require 'rack/lobster'

map '/health' do
  health = proc do |env|
    [200, { "Content-Type" => "text/html" }, ["1"]]
  end
  run health
end

map '/lobster' do
  run Rack::Lobster.new
end

require 'kafka'
require 'elasticsearch'

client = Elasticsearch::Client.new(host: 'elasticsearch:9200', log: true)

kafka = Kafka.new(seed_brokers: ["apache-kafka:9092"])
consumer = kafka.consumer(group_id:"my-consumer")
consumer.subscribe('data')
consumer.each_message do |message|
  data = message.value.split(',')
  client.index(
#  File.open("test","a") do |f|
#   f.puts(
    :index => 'stock',
    :type => 'mytype',
    :body => {
      :Date => Date.parse(data[0]),
      :Open => data[1],
      :High => data[2],
      :Low => data[3],
      :Close => data[4],
      :"Adj Close" => data[5],
      :Volume => data[6],
    }
  )
#  end
end

map '/' do
  welcome = proc do |env|
    [200, { "Content-Type" => "text/html"}, ["Started"]]
  end
  run welcome
end
