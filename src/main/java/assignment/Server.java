// http://localhost:8080/rooms/CG04/tuesday/10:00
package hello;

import java.util.concurrent.atomic.AtomicLong;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.ModelAndView;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

import java.util.*;

@RestController
public class Server {

    private static final String template = "Hello, %s!";
    private final AtomicLong counter = new AtomicLong();
    JSONObject timetable;
    JSONObject rooms;

    @RequestMapping("/")
    public ModelAndView homepage() {
        ModelAndView modelAndView = new ModelAndView("homepage");
        modelAndView.addObject("rooms", this.rooms);
        return modelAndView;
    }

    // JSON endpoints
    @RequestMapping(value="/check/{room_id}/{day}/{time}", method=RequestMethod.GET, produces="text/plain")
    @ResponseBody
    public String checkAvail(@PathVariable("room_id") String room, @PathVariable("day") String day, @PathVariable("time") String time) {
        JSONObject days;
        JSONArray room_obj;
        if (this.timetable.containsKey(day)) {days = (JSONObject) this.timetable.get(day);}
        else {return day + " is not a valid day of the week";}
        
        if (days.containsKey(room)) {room_obj = (JSONArray) days.get(room);}
        else {return room + " is not a valid room";}

        if (time.contains(":") && !time.isEmpty()) {time = time.split(":")[0] + ":00";}
        else {return time + " is not a valid time";}

        for (Object item : room_obj) {
            JSONObject times = (JSONObject) item;
            Integer capacity = Integer.parseInt((String) times.get("capacity"));
                String booked_time = (String) times.get("time");
            
            if (booked_time.equals(time)) {
                if (capacity > 0) {return "Room " + room  + " is available to book on " + day + " at " + time;}
                else {return "Room " + room + " is full on " + day + " at " + time;}
            }

        }
        return "Room " + room + " is available to book on " + day + " at " + time;
    }

    @RequestMapping(value="/rooms/{room}/{day}", method=RequestMethod.GET, produces="application/json")
    @ResponseBody
    public JSONArray getRoomBookingsDay(@PathVariable("room") String room, @PathVariable("day") String day) {
        JSONObject days = (JSONObject) this.timetable.get(day);
        return (JSONArray) days.get(room);
    }

    @RequestMapping(value="/rooms/{room}", method=RequestMethod.GET, produces="application/json")
    @ResponseBody
    public JSONObject getRoomBookingsWeek(@PathVariable("room") String room) {
        JSONObject roomWeek = new JSONObject();
        Set <String> keys = this.timetable.keySet();
        for (String key : keys) {
            JSONObject day = (JSONObject) this.timetable.get(key);
            roomWeek.put(key, day.get(room));
        }
        System.out.println(keys);
        return roomWeek;
    }

    @RequestMapping(value="/list/rooms", method=RequestMethod.GET, produces="application/json")
    @ResponseBody
    public JSONObject getRoomsAndCapacity() {
        return this.rooms;
    }

    @RequestMapping(value="/book/{room}/{day}/{time}", method=RequestMethod.POST)
    @ResponseBody
    public String bookRoom(@PathVariable("room") String room, @PathVariable("day") String day, @PathVariable("time") String time) {
        JSONObject days;
        JSONArray room_obj;
        if (this.timetable.containsKey(day)) {days = (JSONObject) this.timetable.get(day);}
        else {return day + " is not a valid day of the week";}
        
        if (days.containsKey(room)) {room_obj = (JSONArray) days.get(room);}
        else {return room + " is not a valid room";}

        if (time.contains(":") && !time.isEmpty()) {time = time.split(":")[0] + ":00";}
        else {return time + " is not a valid time";}

        for (Object item : room_obj) {
            JSONObject times = (JSONObject) item;
            Integer capacity = Integer.parseInt((String) times.get("capacity"));
            String booked_time = (String) times.get("time");
            
            if (booked_time.equals(time)) {
                if (capacity <= 0) {return "Room " + room + " is full on " + day + " at " + time;}
                else {
                    this.decrementCapacity(times, capacity);
                    return "Room " + room + " has been booked for " + day + " at " + time;
                }
            }

        }
        JSONObject new_time = new JSONObject();
        new_time.put("time", time);
        String cap = (String) this.rooms.get(room);
        Integer cap_int = Integer.parseInt(cap);
        new_time.put("capacity", cap);
        room_obj.add(new_time);
        this.decrementCapacity(new_time, cap_int);
        return "Room " + room + " has been booked for " + day + " at " + time;
    }

    private void decrementCapacity(JSONObject json, int capacity) {
        synchronized (this) {
            try{
                capacity--;
                json.remove("capacity");
                json.put("capacity", String.valueOf(capacity));

                FileWriter file = new FileWriter("src/main/java/assignment/timetable.json");
                file.write(this.timetable.toJSONString());
                System.out.println("Successfully Copied JSON Object to File...");
                file.close();

            }    
            catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    public Server() {
        JSONParser jsonParser = new JSONParser();
         
        try {
            FileReader room_reader = new FileReader("src/main/java/assignment/rooms.json");
            FileReader timetable_reader = new FileReader("src/main/java/assignment/timetable.json");
            //Read JSON file
            Object room_obj = jsonParser.parse(room_reader);
            Object timetable_obj = jsonParser.parse(timetable_reader);
 
            this.rooms = (JSONObject) room_obj;
            this.timetable = (JSONObject) timetable_obj;

            System.out.println(this.rooms);
            System.out.println(this.timetable);
             
        } catch (Exception e) {e.printStackTrace();}
    }
}
