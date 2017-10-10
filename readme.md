********************************************************************************
# Using REDCap API from Stata

Luke Stevens, Murdoch Childrens Research Institute https://www.mcri.edu.au
20-Jun-2017

********************************************************************************
## Acknowledgement
Thanks to Mark Oium, Medical College of Wisconsin, Milwaukee, WI, for example 
of Stata shell command and curl to exchange data with REDCap via the API:
https://community.projectredcap.org/articles/462/api-examples.html (not public)

********************************************************************************
## Background

API is an acronym of "Application Programming Interface", which in English 
translates as a mechanism via which you may interact with a system (in this case
REDCap) from a program, rather than via the regular web-browser interface.

The Stata do-files included here give examples of how you can utilise the REDCap
API to interact with a REDCap project from within Stata without having to log on
to REDCap via your browser in order to download or upload data and/or metadata.
  
### API Documentation
The documentation lists the "API methods" ("functions", if you like) that are 
available and how you can use them.

The REDCap API documentation is available from within the REDCap web application
at https://redcap-url.your-institution.edu/api/help/

### How Might the REDCap API be Useful?  
Logging on to REDCap and downloading data for further processing is a common
task, whether for obtaining raw data for cleaning and analysis purposes, for
preparing summary reports or CONSORT diagrams, or even for just taking a quick
peek at some aspect of a project or its data.

Scripting an API call into your do-file could be a handy time-saver, but also 
enables you to perform your data downloads in a documented and repeatable 
manner. #reproducibleresearch

Note that using the API will not completely replace the browser interface. You
may still wish to download REDCap's regular Stata do-files that contain 
labelling commands, for example.

********************************************************************************
## Preparation

Before you can follow the example do-files you need a REDCap project to access,
an "API token", which functions as your username and password (keep it secret!)
and also a copy of curl, the program that will enable you to communicate 
programmatically with your REDCap server.

### Example Project
You will need access to an instance of REDCap within which you can create new
projects. Download the project XML file provided in this repository and upload
it on REDCap's "Create New Project" page. You now have a new project you can 
use as you like for practice with the REDCap API.

### API Token
You must never write down your REDCap password, and this prohibition extends to
including passwords within program scripts (e.g. a do-file). In order to avoid
having to record passwords this way it is common for APIs to authenticate users
via a user-specific token - an unmemorable string of hexadecimal digits.

Follow these steps to obtain an API token:

1. Navigate to the User Rights page of your new practice project.

2. Click on your username and then "Edit user privileges" 

3. Ensure the "API Export" and "API Import/Update" boxes are ticked, and save

4. Click "API" in the left-hand menu column, then "Request an API token"

Your request requires approval by your REDCap administrator (you should 
receive an email confirmation when it is complete).

5. Return to your project's API page and you will see your token.

The API token below is *ONLY* for you and will work *ONLY with this project*. 
All activity performed using this token is logged as being performed *by you*!
Treat this token like your username and password: it *must NOT be shared with 
others*. 

If you think your token has been compromised, contact your REDCap administrator
immediately AND either delete or regenerate your token.

### API Playground 
REDCap provides the "API Playground" as an area where you can experiment with
the different API methods and parameter options, It enables you to execute 
requests and view corresponding responses, and also generates boilerplate 
scripts in various different programming languages.

Have a play!

You will find that the interactions here are similar to what you do when using 
REDCap via your web browser: you send a request to the server, the server 
processes the request and returns an appropriate response. This is because the 
interaction is performed using the same mechanism: the HTTP protocol (with an 
encrypted connection, hence HTTPS).

### curl
Stata does not have inbuilt functionality for performing http requests (note 
you can load a .dta from an http url via `webuse`, but it does not work using 
https) but does offer the `shell` command, which enables you to pass data to 
other programms on your computer. We can use the popular command-line tool curl
to perform the communication with the REDCap server.

Download a version of curl that is appropriate to your device and operating
system: [https://curl.haxx.se](https://curl.haxx.se) [http://macappstore.org/curl/](http://macappstore.org/curl/)

It does not matter where on your system you copy the curl executable file 
(especially if you include the location in your PATH environment variable) but
for the purposes of the following exercises it is assumed that you have the 
executable at: c:\curl\curl.exe

********************************************************************************
## Do-Files

The following do-files are provided to illustrate different ways the REDCap API
may be used, and different ways in which an appropriate do-file may be 
constructed.

1. Simple_Export.do
    - A basic API call to download all data from your REDCap project.
   
2. Export_Fields_Instruments.do
    - Specify specific fields and instruments to download.
   
3. Export_Filter.do
    - Specify an expression that will filter the records downloaded.
   
4. Export_Report.do
    - Specify a REDCap report to download.
   
5. Export_Metadata.do
    - Illustrating metadata (data dictionary) download - not just records.
   
6. Import_Records.do 
    - Illustrating data import - API is not just for export.

7. Build_Command_String.do 
    - An example of building the curl command programmatically.
   
8. Debugging.do 
    - How to troubleshoot an API call that fails.
   
********************************************************************************
