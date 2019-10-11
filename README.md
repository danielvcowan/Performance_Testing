# Performance_Testing
Simple performance testing to verify valid block chain

## Software Quality Assurance

### Deliverable 4
In this deliverable, you and a partner will write software to verify if a simple blockchain is valid.

Under no circumstances should the program crash or should the user see an exception or stack trace directly. You should handle all edge cases that might be thrown at you, such as a non-existent file, no arguments, different failure modes, etc.

The program shall accept one argument, which is the name of a file which should contain a valid Billcoin blockchain (see billcoin.md in this directory for the rules of Billcoin). Your program will read in and either determine if it is valid (in which case you should print out all of the addresses which have billcoins and how many), or invalid (in which case you should print out what the error is).

The program shall be called verifier.rb. Your repository shall be named D4. This program must be written in Ruby and use minitest for the unit tests. This program must use rubocop with the attached .rubocop.yml configuration and SimpleCov as described in class.

You should work on making this program execute as quickly as possible (i.e., minimize real execution time). You may use all computing resources available to you. This will be run on a four-core system with sixteen gigabytes of RAM. No other programs will be running at the time.

You will use the flamegraph gem to determine execution "hot spots".

You will use the time command (or Measure-Command in Windows) to determine total execution time.

You may experience issues rendering very large flamegraphs on your browser, especially if you use long.txt. Feel free to use the flamegraph for sample.txt or some other very small file if this is the case. If you want to make an even smaller file than sample.txt, you can just make a copy of sample.txt and delete lines from the end. You should still end up with a valid blockchain.

There should be at least twenty unit tests and statement coverage of at least 90%. It is up to you if you would like to use more, use mocks/doubles/stubs or not, etc. There just must be at least twenty valid unit tests and statement coverage of 90% or greater.

You should time the program with the long.txt file three times AND indicate the mean and median amount of real ("wall clock") time it took to execute. You can do this with the time command in Unix-like systems (Linux, OS X, BSD) or the Measure-Command command in PowerShell on Windows systems. All three of these times should be listed ALONG with the MEAN and MEDIAN time to execute the program with long.txt on a separate page.

You must use the flamegraph gem to determine execution "hot spots" and the time command (or Measure-Command for Windows) to determine total execution time, both before and after any changes you make. Include flamegraph screenshots and times from both the initial and final commits on the repo.

Detailed information about Billcoin is in the billcoin.md file in this directory. There are also a variety of sample Billcoin blockchain files in the sample_blockchains subdirectory. See sample_output.txt for the expected output of these files when the verifier is run against them.
