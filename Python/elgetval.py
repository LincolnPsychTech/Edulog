# Get individual value from specified Eduloggers
# "port" is the port Eduloggers are connected to, this is visible on the
# Neulog API window.
# "loggers" is a one dimensional cell array, with each string specifying
# the name of a different Edulogger as described in the Neulog API
# literature:
# https://neulog.com/wp-content/uploads/2014/06/NeuLog-API-version-7.pdf
#
# The output "data" is one row of a structure generated when running an 
# Edulogger experiment, consisting of one field for each kind of Edulogger 
# used, containing the measurements taken at each point in data.Time. 
# Fieldnames should line up with the names specified in "loggers".
import numpy
import requests

def elgetval(port, *varargin):
    varargin = list(map(''.join, varargin)); # Convert varargin to list for ease
    eltypes = numpy.load('eltypes.npy'); # Load possible Edulogger types from file
    loggers = [x for x in varargin if any(x == eltypes)] ; # Extract variable inputs matching valid types
    preface = 'http://localhost:' + str(port) + '/NeuLogAPI?'; # Construct the string to preface any argument passed to the Eduloggers
    
    for (l in loggers) {
            resp = requests.get(preface + 'GetSensorValue:[' + l + '],[1]');
            val = [x for x in list(resp.text) if any(x == list(['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '-']));
    }

    
    return val
    