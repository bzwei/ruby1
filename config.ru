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
    :index => 'stock',
    :type => 'mytype',
    :body => {
      :Date => Date.parse(data[0]),
      :Open => data[1].to_f,
      :High => data[2].to_f,
      :Low => data[3].to_f,
      :Close => data[4].to_f,
      :"Adj Close" => data[5].to_f,
      :Volume => data[6].to_i,
    }
  )
end

map '/' do
  welcome = proc do |env|
    [200, { "Content-Type" => "text/html"}, ["Started"]]
  end
  run welcome
end
