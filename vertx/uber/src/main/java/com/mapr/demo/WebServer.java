package com.mapr.demo;

import io.vertx.core.Vertx;
import io.vertx.core.http.HttpServer;
import io.vertx.ext.web.Router;
import io.vertx.ext.web.handler.StaticHandler;
import io.vertx.ext.web.handler.sockjs.BridgeOptions;
import io.vertx.ext.web.handler.sockjs.PermittedOptions;
import io.vertx.ext.web.handler.sockjs.SockJSHandler;

import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;

import java.util.Arrays;
import java.util.Collections;
import java.util.Properties;

public class WebServer {

    //public static String uberTopic101 = "ansotopic101";
    public static String uberTopic;
    static int httpPort;
    //public static String httpHost = "192.168.99.100";
    //public static String httpHost = "vertx";
    public static String httpHost = "0.0.0.0";

    public static void main(String[] args) throws Exception {

        if (args.length != 2) {
            throw new IllegalArgumentException("Must have the HtttPort and Topic :  8080 /apps/iot_stream:ecg  ");
        }
        httpPort = Integer.parseInt(args[0]);
        uberTopic = args[1];

        System.out.println("WebServer: Port:"+httpPort+" Topic: "+uberTopic);

        if (uberTopic.equals("ansotopic100")){

            Vertx vertx = Vertx.vertx();
            Router router = Router.router(vertx);

            BridgeOptions options = new BridgeOptions();
            //options.setOutboundPermitted(Collections.singletonList(new PermittedOptions().setAddress("dashboard")));

            options.addOutboundPermitted(new PermittedOptions().setAddress("dashboard"));
            //options.addInboundPermitted(new PermittedOptions().setAddress("dashboard"));
            options.addOutboundPermitted(new PermittedOptions().setAddress("sales"));
            //options.addInboundPermitted(new PermittedOptions().setAddress("sales"));

            router.route("/eventbus/*").handler(SockJSHandler.create(vertx).bridge(options));
            router.route("/*").handler(StaticHandler.create().setCachingEnabled(false));


            HttpServer httpServer = vertx.createHttpServer();
            httpServer.requestHandler(router::accept).listen(httpPort, httpHost, ar -> {
                if (ar.succeeded()) {
                    System.out.println("Http server started started on port " + httpPort);
                } else {
                    ar.cause().printStackTrace();
                }
            });

            // Create a MapR Streams Consumer
            Properties properties = new Properties();
            properties.setProperty("group.id", "vertx_dashboard");
            properties.setProperty("enable.auto.commit", "true");
            properties.setProperty("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
            properties.setProperty("value.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
            properties.setProperty("bootstrap.servers","192.168.99.100:9092");
            properties.setProperty("listeners","192.168.99.100:9092");

            KafkaConsumer<String, String> consumer = new KafkaConsumer<>(properties);
            consumer.subscribe(Arrays.asList(uberTopic.trim()));
            System.out.println("***consume from Kafka Topic: [" + uberTopic + "] publish to eventbus dashboard***");

//        KafkaConsumer<String, String> consumer101 = new KafkaConsumer<>(properties);
//        consumer101.subscribe(Arrays.asList(uberTopic101.trim()));

            while (true) {
                ConsumerRecords<String, String> records = consumer.poll(200);
                System.out.println("***Getting "+records.count()+" records from kafka topic "+uberTopic.trim()+" ***");
                for (ConsumerRecord<String, String> record : records) {
                    vertx.eventBus().publish("dashboard", record.value());
                    System.out.println(record.value());
                }

//            ConsumerRecords<String, String> records101 = consumer101.poll(200);
//            System.out.println("***Getting "+records101.count()+" records from kafka topic "+uberTopic101.trim()+" ***");
//            for (ConsumerRecord<String, String> record : records101) {
//                vertx.eventBus().publish("sales", record.value());
//                System.out.println(record.value());
//            }


            }


        }
        else {

            Vertx vertx = Vertx.vertx();
            Router router = Router.router(vertx);

            BridgeOptions options = new BridgeOptions();
            //options.setOutboundPermitted(Collections.singletonList(new PermittedOptions().setAddress("dashboard")));

            options.addOutboundPermitted(new PermittedOptions().setAddress("dashboard"));
            //options.addInboundPermitted(new PermittedOptions().setAddress("dashboard"));
            options.addOutboundPermitted(new PermittedOptions().setAddress("sales"));
            //options.addInboundPermitted(new PermittedOptions().setAddress("sales"));

            router.route("/eventbus/*").handler(SockJSHandler.create(vertx).bridge(options));
            router.route("/*").handler(StaticHandler.create().setCachingEnabled(false));


            HttpServer httpServer = vertx.createHttpServer();
            httpServer.requestHandler(router::accept).listen(httpPort, httpHost, ar -> {
                if (ar.succeeded()) {
                    System.out.println("Http server started started on port " + httpPort);
                } else {
                    ar.cause().printStackTrace();
                }
            });

            // Create a MapR Streams Consumer
            Properties properties = new Properties();
            properties.setProperty("group.id", "vertx_dashboard");
            properties.setProperty("enable.auto.commit", "true");
            properties.setProperty("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
            properties.setProperty("value.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
            properties.setProperty("bootstrap.servers","192.168.99.100:9092");
            properties.setProperty("listeners","192.168.99.100:9092");

            KafkaConsumer<String, String> consumer = new KafkaConsumer<>(properties);
            consumer.subscribe(Arrays.asList(uberTopic.trim()));
            System.out.println("***consume from Kafka Topic: [" + uberTopic + "] publish to eventbus dashboard***");

            while (true) {
                ConsumerRecords<String, String> records = consumer.poll(200);
                System.out.println("***Getting "+records.count()+" records from kafka topic "+uberTopic.trim()+" ***");
                for (ConsumerRecord<String, String> record : records) {
                    vertx.eventBus().publish("sales", record.value());
                    System.out.println(record.value());
                }

            }

        }

    }
}
