.pragma library

function milliSecondsToString(milliseconds) {
    milliseconds = milliseconds > 0 ? milliseconds : 0;
    var timeInSeconds = Math.floor(milliseconds / 1000);
    var minutes = Math.floor(timeInSeconds / 60);
    var minutesString = minutes < 10 ? "0" + minutes : minutes;
    var seconds = Math.floor(timeInSeconds % 60);
    var secondsString = seconds < 10 ? "0" + seconds : seconds;
    return minutesString + ":" + secondsString;
}

function secondsToString(seconds) {
    return milliSecondsToString(seconds*1000);
}

function formatDate(dateString) {
    // Split the given dateString.
    // It's formatted in ISO 8601 (such as 2000-01-01T12:00:00.000Z).
    var dateStr = dateString.substring(0, 10);
    var timeStr = dateString.substring(11, dateString.length-1);

    var date = convertToDate(dateStr, timeStr);
    return date.getDate() + "/" + date.getMonth() + "/" + date.getFullYear();
}

function convertToDate(date, time) {
    // "Constant" definition. Define for the parseInt to use decimal system.
    var RADIX = 10;

    // Convert ISO 8601 representation of date to JS Date.
    var newDate = new Date(parseInt(date.substr(0,4), RADIX),  // Parses the year (4 digits)
                           parseInt(date.substr(5,2), RADIX)-1,// Parses the month (2 digits)
                           parseInt(date.substr(8,2), RADIX)); // Parses the day (2 digits)
    // If time was given, add it as well.
    if(time) {
        // Set hours, 0-11
        newDate.setHours(parseInt(time.substr(0,2), RADIX));
        // Set minutes, 0-59
        newDate.setMinutes(parseInt(time.substr(3,2), RADIX));
        // Set seconds, 0-59
        newDate.setSeconds(parseInt(time.substr(6,2), RADIX));
        // Set milliseconds, 0-999
        newDate.setMilliseconds(parseInt(time.substr(9,2), RADIX));
    }

    return newDate;
}
