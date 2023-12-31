<%@ page import="java.time.LocalDate" %>
<%@ page import="data.entity.User" %>
<%@ page import="data.entity.Person" %>
<%@ page import="data.entity.PersonDay" %>
<%@ page import="java.util.List" %>
<%@ page import="dto.payload.PersonDayDTO" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Map" %>
<%@ page import="dto.payload.PersonDTO" %>
<%@ page import="com.google.protobuf.Internal" %>
<%@ page import="java.util.UUID" %>
<!-- In supervisorPage.jsp -->
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>Work time Monitoring</title>
    <%@include file="/WEB-INF/HTML/navbar.html"%>
    <style>
        <%@include file="/WEB-INF/css/navbar.css"%>
        <%@include file="/WEB-INF/css/attendance-control.css"%>
    </style>
    <script>

        document.addEventListener('DOMContentLoaded', function() {
            var cells = document.querySelectorAll('td[data-day]');
            var popup = document.querySelector('.popup');

            cells.forEach(function(cell) {
                cell.addEventListener('click', function(event) {
                    var cellText = cell.textContent;
                    var personName = cell.parentElement.querySelector('td:first-child').textContent;
                    var id = cell.parentElement.querySelector('td:last-child').textContent;
                    var dayDate = cell.getAttribute('data-day');

                    // Update the popup content with person name, day date, and times
                    var popupContent = `
                   <div class="popup-content">
                        <span class="popup-close" id="popup-close" onclick="closePopup();">&times;</span>
                        <h2 style="clear:both">Update Schedule</h2>
                        <p>Name: ${personName}</p>
                        <p>Day Date: ${dayDate}</p>
                        <label for="startTime" class="popup-input">Start Time: <input type="time" name="startTime" id="startTime" step="60" required></label><br>
                        <label for="endTime" class="popup-input">End Time: <input type="time" name="endTime" id="endTime" step="60" required></label><br>
                        <button class="popup-button" id="popup-button" onclick="updateSchedule('${personName}', '${dayDate}', '${id}');">Update</button>
                        <p id="errorMessage" style="color: red; display: none;">Times must be filled.</p>
                    </div>
                `;
                    popup.innerHTML = popupContent;

                    function positionPopup() {
                        var cellRect = cell.getBoundingClientRect();
                        var cellBottomRightX = cellRect.left;
                        var cellBottomRightY = cellRect.top + cellRect.height;
                        var popupWidth = popup.offsetWidth;
                        var popupHeight = popup.offsetHeight;
                        var offsetX = cellBottomRightX;
                        var offsetY = cellBottomRightY;

                        // Display the popup near the clicked cell
                        popup.style.display = 'block';
                        popup.style.left = offsetX + 'px';
                        popup.style.top = offsetY + 'px';
                    }

                    // Use requestAnimationFrame to execute the positioning code
                    window.requestAnimationFrame(positionPopup);

                    // Close the popup on "Esc" key press
                    document.addEventListener('keydown', function(event) {
                        if (event.key === 'Escape') {
                            closePopup();
                        }
                    });
                });
            });
        });

        function closePopup() {
            document.querySelector('.popup').style.display = 'none';
        }

        function updateSchedule(personName, dayDate, id) {
            // Get the updated start time and end time from the input fields
            var startTime = document.getElementById('startTime').value;
            var endTime = document.getElementById('endTime').value;
            var errorMessageElement = document.getElementById('errorMessage');

            // Check if start and end times are filled
            if (startTime && endTime) {
                // Create a new AJAX request
                var xhr = new XMLHttpRequest();
                xhr.open('POST', 'attendanceControl', true);
                xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
                xhr.onreadystatechange = function () {
                    if (xhr.readyState === 4 && xhr.status === 200) {
                        // Handle the response from the server
                        console.log(xhr.responseText);
                    }
                };


                var params = 'personId=' + encodeURIComponent(id) +
                    '&dayDate=' + encodeURIComponent(dayDate) +
                    '&startTime=' + encodeURIComponent(startTime)+
                    '&endTime=' + encodeURIComponent(endTime);

                console.log(params);
                xhr.send(params);
                // Hide the error message if it was previously shown
                errorMessageElement.style.display = 'none';

                closePopup();
            } else {
                // Show the error message
                errorMessageElement.style.display = 'block';
            }
        }


    </script>
</head>
<body>
<div class="table-container">
    <h1>Person Schedule</h1>
    <table>
        <%
            PersonDTO person  = (PersonDTO) request.getAttribute("name");
            String personName = person.getPersonName();
            List<PersonDayDTO> personDayList = (List<PersonDayDTO>) request.getAttribute("dayList");
            UUID personId = person.getPersonId();
            SimpleDateFormat hhmmFormat = new SimpleDateFormat("HH:mm");
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        %>
        <tr>
            <th>Name</th>
            <% for (PersonDayDTO p : personDayList) { %>
            <% if (p != null && p.getAccountingDate() != null) { %>
            <th><%= dateFormat.format(p.getAccountingDate()) %></th>
            <% } %>
            <% } %>
        </tr>
        <tr>
            <td><%=personName %></td>
            <% for (PersonDayDTO p : personDayList) { %>
            <% if (p != null && p.getStartTime() != null && p.getEndTime() != null) { %>
            <td id="<%=p.getPersonDayId()%>" data-day="<%= p.getAccountingDate() %>"><%= hhmmFormat.format(p.getStartTime()) + " - " + hhmmFormat.format(p.getEndTime()) %></td>
            <% } else { %>
            <td id="<%=p.getPersonDayId()%>" data-day="<%= dateFormat.format(p.getAccountingDate()) %>"></td>
            <% } %>
            <% if (p.getWeekend()) {%>
            <script>
                document.getElementById('<%=p.getPersonDayId()%>').style.backgroundColor = '#a9f468';
                document.getElementById('<%=p.getPersonDayId()%>').onmouseenter = function () {document.getElementById('<%=p.getPersonDayId()%>').style.backgroundColor = '#4bf457'}
                document.getElementById('<%=p.getPersonDayId()%>').onmouseleave = function () {document.getElementById('<%=p.getPersonDayId()%>').style.backgroundColor = '#a9f468'}
            </script>
            <% } %>
            <% if (p.getHoliday()) {%>
            <script>
                document.getElementById('<%=p.getPersonDayId()%>').style.backgroundColor = '#eff45a';
                document.getElementById('<%=p.getPersonDayId()%>').onmouseenter = function () {document.getElementById('<%=p.getPersonDayId()%>').style.backgroundColor = '#f4db00'}
                document.getElementById('<%=p.getPersonDayId()%>').onmouseleave = function () {document.getElementById('<%=p.getPersonDayId()%>').style.backgroundColor = '#eff45a'}
            </script>
            <% } %>
            <% } %>
            <td style="display: none;"><%= personId%></td>
        </tr>


        <%
            Map<PersonDTO, List<PersonDayDTO>> map  = (Map<PersonDTO, List<PersonDayDTO>>) request.getAttribute("map");
            for (java.util.Map.Entry<PersonDTO, List<PersonDayDTO>> entry : map.entrySet()) {
                PersonDTO pers = entry.getKey();
                personId = pers.getPersonId();
                List<PersonDayDTO> days = entry.getValue();%>
        <tr>
            <td><%=pers.getPersonName() %></td>
            <% for (PersonDayDTO p : days) { %>
            <% if (p != null && p.getStartTime() != null && p.getEndTime() != null) { %>
            <td id="<%=p.getPersonDayId()%>" data-day="<%= p.getAccountingDate() %>"><%= hhmmFormat.format(p.getStartTime()) + " - " + hhmmFormat.format(p.getEndTime()) %></td>
            <% } else { %>
            <td id="<%=p.getPersonDayId()%>" data-day="<%=dateFormat.format(p.getAccountingDate()) %>"></td>
            <% } %>
            <% if (p.getWeekend()) {%>
            <script>
                document.getElementById('<%=p.getPersonDayId()%>').style.backgroundColor = '#a9f468';
                document.getElementById('<%=p.getPersonDayId()%>').onmouseenter = function () {document.getElementById('<%=p.getPersonDayId()%>').style.backgroundColor = '#4bf457'}
                document.getElementById('<%=p.getPersonDayId()%>').onmouseleave = function () {document.getElementById('<%=p.getPersonDayId()%>').style.backgroundColor = '#a9f468'}
            </script>
            <% } %>
            <% if (p.getHoliday()) {%>
            <script>
                document.getElementById('<%=p.getPersonDayId()%>').style.backgroundColor = '#eff45a';
                document.getElementById('<%=p.getPersonDayId()%>').onmouseenter = function () {document.getElementById('<%=p.getPersonDayId()%>').style.backgroundColor = '#f4db00'}
                document.getElementById('<%=p.getPersonDayId()%>').onmouseleave = function () {document.getElementById('<%=p.getPersonDayId()%>').style.backgroundColor = '#eff45a'}
            </script>
            <% } %>
            <% } %>

            <td style="display: none;"><%= personId%></td>
        </tr>

        <%}%>

    </table>
</div>

<!-- Popup box -->
<div class="popup"></div>
</body>
</html>