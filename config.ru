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
map '/' do
  kafka = Kafka.new(seed_brokers: ["apache-kafka:9092"])

  kafka.each_message(topic: "greetings") do |message|
    open('kout','a') {|f| f.puts message.value}
  end  
  welcome = proc do |env|
    [200, { "Content-Type" => "text/html"}, ["Started"]]
  end
  run welcom
end
