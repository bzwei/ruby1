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
kafka = Kafka.new(seed_brokers: ["apache-kafka:9092"])
consumer = kafka.consumer(group_id:"my-consumer")
consumer.subscribe('data')
kafka.each_message do |message|
  open('kout','a') {|f| f.puts message.value}
end

map '/' do
  welcome = proc do |env|
    [200, { "Content-Type" => "text/html"}, ["Started"]]
  end
  run welcome
end
