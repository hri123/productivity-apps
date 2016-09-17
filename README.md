# productivity-apps

__Goal:__ coming up with scripts / applications that will help manage my personal calendar

## To manage both events and reminders in the same app, currently using WeekCal for its rolling event feature

Can implement the Rolling event feature in two ways:

- Google Apps Script

It is very easy to write script, but the major downside is, if the event is edited offline in both desktop (cloud directly) and on phone, the event on the phone gets overwritten by what is on the desktop even if the event on the phone is newer. So, if the script updates the event on the cloud, that overwrites whatever edit that happens on the phone.

- ios App

Difficult to code and install on phones, but the advantage is that it updates the events locally thereby not ending up losing any updates to the events.
