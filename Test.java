import java.util.*;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;

public class Test implements Runnable {
    private String [] days = {"monday", "tuesday", "wednesday", "thursday", "friday", "asdf"}; 
    private String [] rooms = {"L211", "T101", "XG14", "CG04", "asdf"}; 
    private String url = "http://localhost:8080/";
    private String [] endpoints = {"BOOK", "CHECK"};
    public void run() {
        int requestCount = 0;
        long id = Thread.currentThread().getId();
        while (requestCount <= 100) {
            int interval = (int) Math.round(Math.random() * 200);
            if (interval > 150) { // generate at random times
                try {
                    FileWriter fw = new FileWriter(new File("./test_output.txt"), true);
                    int ep_index = (int) Math.floor(Math.random() * endpoints.length);

                    URL obj;

                    String day = days[(int) Math.round(Math.random() * (days.length - 1))];
                    String room = rooms[(int) Math.round(Math.random() * (rooms.length - 1))];
                    String time;

                    Random random = new Random();
                    int hour = random.nextInt(17 - 9) + 9; // get a number between 9 and 17
                    if (hour == 9) {time = "09:00";} 
                    else {time = hour + ":00";}

                    String params;

                    if (endpoints[ep_index].equals("BOOK")) {
                        obj = new URL(url + "book/" + room + "/" + day + "/" + time);
                        HttpURLConnection con = (HttpURLConnection) obj.openConnection();
                        con.setRequestMethod("POST");
                        params = "?room=" + room + "&day=" + day + "&time=" + time;
                        con.setDoOutput(true);

                        DataOutputStream wr = new DataOutputStream(con.getOutputStream());
                        wr.writeBytes(params);
                        wr.flush();
                        wr.close();

                        int responseCode = con.getResponseCode();

                        BufferedReader in = new BufferedReader(
                                new InputStreamReader(con.getInputStream()));
                        String inputLine;
                        StringBuffer response = new StringBuffer();

                        while ((inputLine = in.readLine()) != null) {
                            response.append("Thread: " + String.valueOf(id) + "; Action: " + endpoints[ep_index] + "\n");
                            response.append("\t" + inputLine);
                        }
                        in.close();
                        
                        //print result
                        System.out.println(response.toString());
                        fw.write(response.toString() + "\n");
                        fw.close();
                    }
                    else {
                        obj = new URL(url + "check/" + room + "/" + day + "/" + time);
                        HttpURLConnection con = (HttpURLConnection) obj.openConnection();
                        con.setDoOutput(true);
                        
                        // System.out.println(day);
                        // System.out.println(room);
                        // System.out.println(time);
                        BufferedReader in = new BufferedReader(
                            new InputStreamReader(con.getInputStream()));
                        String inputLine;
                        StringBuffer response = new StringBuffer();

                        while ((inputLine = in.readLine()) != null) {
                            response.append("Thread: " + String.valueOf(id) + "; Action: " + endpoints[ep_index] + "\n");
                            response.append("\t" + inputLine);
                        }
                        in.close();

                        //print result
                        System.out.println(response.toString());
                        fw.write(response.toString() + "\n");
                        fw.close();
                    }

                } catch(Exception e) {e.printStackTrace();}
            }
            else {
                try {
                    Thread.sleep(interval);
                } catch(Exception e) {}
            }
        }
    }

    public static void main(String [] args) {
        Thread t1 = new Thread(new Test());
        Thread t2 = new Thread(new Test());
        Thread t3 = new Thread(new Test());
        t1.start();
        t2.start();
        t3.start();
    }
}
