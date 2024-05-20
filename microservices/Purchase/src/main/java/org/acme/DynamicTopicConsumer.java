package org.acme;

import org.apache.kafka.clients.consumer.Consumer;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import java.time.Duration;
import java.util.Collections;
import java.util.Properties;
import org.json.*;

import jakarta.inject.Inject;


public class DynamicTopicConsumer extends Thread  {
    private String kafka_servers;
    private String topic;

     @Inject
    io.vertx.mutiny.mysqlclient.MySQLPool client;
    

    public DynamicTopicConsumer(String topic_received , String kafka_servers_received , io.vertx.mutiny.mysqlclient.MySQLPool client_received)  
    {
        topic = topic_received;
        kafka_servers = kafka_servers_received;
        client = client_received;
    }

    public void run() 
	{
	    try 
		{
            Properties properties = new Properties();
            properties.put("bootstrap.servers", kafka_servers);
            properties.put("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
            properties.put("value.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
            properties.put("group.id", "your-group-id");
    
            try (Consumer<String, String> consumer = new KafkaConsumer<>(properties)) {
                consumer.subscribe(Collections.singletonList(topic));
    
                while (true) {
                    ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(100));
                    for (ConsumerRecord<String, String> record : records)
                    {
/*                       System.out.printf("topic = %s, partition = %s, offset = %d,key = %s, value = %s\n",
                      record.topic(), record.partition(), record.offset(),
                      record.key(), record.value());				
*/

                      String jsonString = record.value() ; 
                      JSONObject obj = new JSONObject(jsonString);
                      String timestamp = obj.getJSONObject("Purchase_Event").getString("TimeStamp");
                      String price = obj.getJSONObject("Purchase_Event").getString("Price");
                      String product = obj.getJSONObject("Purchase_Event").getString("Product");
                      String supplier = obj.getJSONObject("Purchase_Event").getString("Supplier");
                      String shop_name = obj.getJSONObject("Purchase_Event").getString("Shop");
                      String loyaltyCard_id = obj.getJSONObject("Purchase_Event").getString("LoyaltyCard_ID");

                      String query = "INSERT INTO Purchases (DateTime,Price,Product,Supplier,shopname,loyaltycardid) VALUES ("
                      + "'" + timestamp + "',"
                      + "'" + price + "',"
                      + "'" + product + "',"
                      + "'" + supplier + "',"
                      + "'" + shop_name + "',"
                      + loyaltyCard_id  
                      + ")";

                      client.query(query).execute().await().indefinitely();
                    }
                }
            }    
        }
        catch (Exception e) 
		{  System.out.println("Exception is caught");  }
    }
}
