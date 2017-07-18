require 'kafka'

kafka = Kafka.new(seed_brokers:["apache-kafka:9092"])
producer = kafka.producer

File.open('RHT2.csv').each_with_index do |line, no|
  next if no < 2
  producer.produce(line, topic: "data")
  producer.deliver_messages if no % 100 == 0
end

producer.deliver_messages

