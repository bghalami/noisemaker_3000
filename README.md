[![Maintainability](https://api.codeclimate.com/v1/badges/d31065e0c844061096b3/maintainability)](https://codeclimate.com/github/bghalami/noisemaker_3000/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/d31065e0c844061096b3/test_coverage)](https://codeclimate.com/github/bghalami/noisemaker_3000/test_coverage)

# NOISEMAKER_3000
Welcome, to the wild world of generating nonsense for your EDR to collect.  
This app can create a specified file type, append a short message to any .txt file, and delete any file.
It can also generate an outgoing network request.

## Interacting with the App
This was written with Ruby version 3.1.1, so go install that.  
All processes write to the log file, which will generate itself in the `/log/` directory.

## Once installed you can interact with the app through the command line
You'll use the runner file, `make_some_noise.rb` located in the lib directory  
run `ruby <path/to/make_some_noise.rb> --help` for a list of all available commands  
(All following functionality was tested in Unix, Linux, and Windows, and functioned as expected*)

### File Modification
#### Create
`ruby <path/to/make_some_noise.rb> --filepath "path/to/file/new_file.txt" --create`
#### Modify
`ruby <path/to/make_some_noise.rb> --filepath "path/to/file/existing_file.txt" --modify`
#### Delete
`ruby <path/to/make_some_noise.rb> --filepath "path/to/file/existing_file.txt" --delete`

### Network Noise Generation
`ruby <path/to/make_some_noise.rb> --generate-network-traffic`


## Some Techy Things!
### Network Handler
> Per the requirements of the challenge, I leveraged TCPSockets to open a client and push data through. We get a 400 Bad Request response because Google isn't interested in taking random http requests, but I believe it meets the requirements of establishing a network connection, and transmitting data.  
  
### File Handler
> I leveraged Ruby's built in File, Dir, and FileUtils modules to handle creating, modifying, and deleting files.

### NoisemakerLogger
> I built a custom logger using Ruby's built in JSON, File, and Dir modules to create a `.json` log file which outputs every requested log of the program.

### Option Handler
> I leveraged Ruby's built in OptionParser module to handle command line options and interaction.
  

## What I Would Change
#### 1) Move repeated logic to helper class(es)
> There are several pieces of logic in the code that could be moved to their own helper class.  
e.g.```
dirname = File.dirname(filepath)
Dir.mkdir(dirname) unless File.directory?(dirname)```
#### 2) Repeated logic in specs could be moved to spec_helper
#### 3) There are opportunities to implement shared examples in the specs  
> More specifically around file manipulation.
#### 4) Implement a factory system for testing more randomized testing
#### 5) Look into Linux functionality
> For some reason, which I couldn't quickly deduce, the log file on Linux is created in the lib directory.
#### 6) Ask more questions
> Now that I'm at the end of my project I realize I made some assumptions, but feel pressured by time to submit.  
If I could do it again I would have asked more questions as soon as I ran into them.
Primarily around the networking portion.



