#!/usr/bin/env python
from ecmwfapi import ECMWFDataServer
server = ECMWFDataServer()
server.retrieve({
    "class": "ei",
    "dataset": "interim",
    "date": "2015-01-01",
    "expver": "1",
    "levelist": "46/to/60",
    "levtype": "ml",
    "param": "131.128/132.128",
    "step": "0",
    "stream": "oper",
    "target": "20150101_U_V_ml.nc",
    "time": "00/06/12/18",
    "type": "an",
	"area": "70/-10/35/70",
	"format": "netcdf",
	"grid": "0.36/0.36"
	})
