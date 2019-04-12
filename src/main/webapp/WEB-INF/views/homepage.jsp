<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>

<!DOCTYPE html>
<html>
<body>
    <script>
        var rooms
        window.onload = function() {
            var xhttp = new XMLHttpRequest()
            xhttp.onreadystatechange = function() {
                if (this.readyState == 4 && this.status == 200) {
                    rooms = JSON.parse(this.responseText)
                    console.log(rooms)

                    var l211 = document.getElementsByClassName('L211');
                    var xg14 = document.getElementsByClassName('XG14');
                    var cg04 = document.getElementsByClassName('CG04');
                    var t101 = document.getElementsByClassName('T101');

                    for (var i = 0; i < l211.length; i++) {
                        l211.item(i).innerHTML = "L211 size: " + rooms["L211"]
                        cg04.item(i).innerHTML = "CG04 size: " + rooms["CG04"]
                        t101.item(i).innerHTML = "T101 size: " + rooms["T101"]
                        xg14.item(i).innerHTML = "XG14 size: " + rooms["XG14"]
                    }
                }
            }
            xhttp.open('GET', '/list/rooms')
            xhttp.send()
        }
        var count_tries = 0
        var weekdays = {"monday":1, "tuesday":2, "wednesday":3, "thursday":4, "friday":5}
        var xhttp = new XMLHttpRequest(); 

        function send_timetable (url, action, data) {
            xhttp.onreadystatechange = function() {
                if (this.readyState == 4 && this.status == 200) {
                    console.log(this.responseText)
                    var res = JSON.parse(this.responseText)
                    for (var i = 1; i < 9; i++) { for (var j = 1; j <5; j++) document.getElementById('timetable').rows[j].cells[i].innerHTML = ""}
                    for (day in res) {
                        console.log(day)
                        res[day].forEach(function(time) {
                            timeSplit = time.time.split(":")	
                            index = parseInt(timeSplit[0]) - 8 
                            document.getElementById("timetable").rows[weekdays[day]].cells[index].innerHTML = time.capacity;
                        })
                    }   
                            
                }
                xhttp.onerror = function(e) {
                    console.log(data.room) // defined
                    handle_error('message2', data, "VIEW")
                }
            }
            xhttp.open(action, url)
            xhttp.send();       
        }

        function book(url, action, params, data) {
            var xhttp = new XMLHttpRequest();
            xhttp.onreadystatechange = function() {
                if (this.readyState == 4 && this.status == 200) {
                    document.getElementById("message2").innerHTML = this.responseText
                }
                xhttp.onerror = function() {
                    handle_error('message2', data, "BOOK")
                }
            }
            xhttp.open(action, url)
            xhttp.send(params);
        }

        function check(url, action, data) {
            var xhttp = new XMLHttpRequest();
            xhttp.onreadystatechange = function() {
                if (this.readyState == 4 && this.status == 200) {
                    document.getElementById("message1").innerHTML = this.responseText
                }
                xhttp.onerror = function() {
                    handle_error('message1', data, "BOOK")
                }
            }
            xhttp.open(action, url)
            xhttp.send();
        }

        function room_week (data) {
            if (data) {
                console.log(data.room) // undefined
                var room = data.room
            }
            else {
                var room = document.getElementById('room_week_room').value
            }
            if (!room) {document.getElementById('message2').innerHTML = 'Please fill in all available fields of the form'}
            else {send_timetable('/rooms/' + room, 'GET', {room:room})}
        }

        function check_avail(data) {
            if (data) {
                var room = data.room
                var day = data.day
                var time = data.time
            }
            else {
                var room = document.getElementById('check_room').value
                var day = document.getElementById('check_day').value
                var time = document.getElementById('check_time').value
            }
            console.log(room + ' ' + day + ' ' + time)
            if (!room || !day || !time) {document.getElementById('message1').innerHTML = 'Please fill in all available fields of the form'}
            else {check('/check/' + room + '/' + day + '/' + time, 'GET', {room:room, day:day, time:time})}
        }

        function book_room (data) {
            if (data) {
                var time = data.time
                var day = data.day
                var room = data.room
            }
            else {
                var time = document.getElementById('time_selection').value
                var day = document.getElementById('day_selection').value
                var room = document.getElementById('room_selection').value
            }
            console.log(room + ' ' + day + ' ' + time)
            if (!room || !day || !time) {document.getElementById('message2').innerHTML = 'Please fill in all available fields of the form'}
            var params = "room=" + room + "&day=" + day + "&time=" + time
            if (!room || !day || !time) {document.getElementById('message1').innerHTML = 'Please fill in all available fields of the form'}
            else {book('/book/' + room + "/" + day + "/" + time, "POST", params, {room:room, day:day, time:time})}
        }

        function handle_error(id, data, request) {
            if (data) console.log(data.room) // defined 
            if (count_tries < 3) {
                document.getElementById(id).innerHTML = "Couldn't process your request, retrying...";
                if (request == "VIEW") {
                   room_week(data) 
                }
                else if (request == "BOOK") {
                    book_room(data)
                }
                else if (request == "CHECK") {
                    check_avail(data)
                }
                count_tries++
            }
            
            else {
                document.getElementById(id).innerHTML = "Retried your request and couldn't connect to the server, please try again later."
                count_tries = 0
            }
        }
      
    </script>
    <style>
        #timetable {
            font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
            border-collapse: collapse;
            width: 100%;
        }

        #timetable td, #timetable th {
            border: 1px solid #ddd;
            padding: 8px;
        }

        #timetable tr:nth-child(even){background-color: #f2f2f2;}

        #timetable tr:hover {background-color: #ddd;}

        #timetable th {
            padding-top: 12px;
            padding-bottom: 12px;
            text-align: left;
            background-color: #4CAF50;
            color: white;
        }
    </style>

    <h1>Room booking service</h1>
    <h2>Check Availability of a room!</h2>
    <br>
    <form id="room_check">
    <label path="room">Select a room!</label>
    <select name = "rooms" path="room" id="check_room">
        <option value="L211" class="L211">L211 size ${rooms.get("L221")}</option>
        <option value="XG14" class="XG14">XG14 size ${rooms.get("XG14")}</option>
        <option value="T101" class="T101">T101 size ${rooms.get("T101")}</option>
        <option value="CG04" class="CG04">CG04 size ${rooms.get("CG04")}</option>
    </select>

    <label path="time">Select a time</label>
    <input type= "time" name ="time" path="time" id="check_time"/>

    <label path="day">Select a day</label>
    <select name = "days" path="day" id="check_day">
        <option value="monday">Monday</option>
        <option value="tuesday">Tuesday</option>
        <option value="wednesday">Wednesday</option>
        <option value="thursday">Thursday</option>
        <option value="friday">Friday</option>
    </select>
    <br><br>


    </form>
    <button onclick="check_avail()">Check Availability</button>
    <h2 style="color:${color};" id="message1">${msg}</h2>

    <br><br><br>
    <h2>Book a room!</h2>
    <p>Click the room from the dropdown below</p>

    <form id="room_book">
    <label>Select a room!</label>
    <select name = "rooms" id = "room_selection">
        <option value="L211" class="L211">L211 size ${rooms.get("L221")}</option>
        <option value="XG14" class="XG14">XG14 size ${rooms.get("XG14")}</option>
        <option value="T101" class="T101">T101 size ${rooms.get("T101")}</option>
        <option value="CG04" class="CG04">CG04 size ${rooms.get("CG04")}</option>
    </select>

    <label>Select a time</label>
    <input type= "time" name ="time" id = "time_selection"/>

    <label >Select a day</label>
    <select name = "days" path="day" id = "day_selection">
        <option value="monday">Monday</option>
        <option value="tuesday">Tuesday</option>
        <option value="wednesday">Wednesday</option>
        <option value="thursday">Thursday</option>
        <option value="friday">Friday</option>
    </select>
    <br><br>
    </form>
    <button  onclick="book_room()">Book Room</button>
    <h2 style="color:${color};" id="message2">${msg}</h2>

    <br><br><br>
    <h2>View a room's timetable for the week!</h2>
    <br>
    <form id="week_book">
        <label path="room">Select a room!</label>
        <select name = "rooms" path="room" id = "room_week_room">
            <option value="L211" class="L211">L211 size ${rooms.get("L221")}</option>
            <option value="XG14" class="XG14">XG14 size ${rooms.get("XG14")}</option>
            <option value="T101" class="T101">T101 size ${rooms.get("T101")}</option>
            <option value="CG04" class="CG04">CG04 size ${rooms.get("CG04")}</option>
        </select>
    </form>

    <button onclick="room_week()">Submit</button>
    <br><br><br>
<table id = "timetable" style="border:1px;">
<tbody>
<tr>
<td>&nbsp;</td>
<td>09:00</td>
<td>10:00</td>
<td>11:00</td>
<td>12:00</td>
<td>13:00</td>
<td>14:00</td>
<td>15:00</td>
<td>16:00</td>
<td>17:00</td>
</tr>
<tr>
<td>Monday</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
</tr>
<tr>
<td>Tuesday</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
</tr>
<tr>
<td>Wednesday</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
</tr>
<tr>
<td>Thursday</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
</tr>
<tr>
<td>Friday</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
</tr>
</tbody>
</table>
<script>
</script>
</body>
<html> 

