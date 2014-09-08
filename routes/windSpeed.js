//
// module for setting Wind Speed of the wind fan
//
var serialListener = require('../lib/serialListener');

var express = require('express');
var router = express.Router();

// middleware specific to this route, logs timestamps
router.use(function timeLog(req, res, next){
	console.log('windSpeed Time: ', Date.now());
	next();
})

// define the home page route
router.get('/', function(req, res){
console.log('windSpeed get');
 	res.redirect('index');
})

router.post('/', function(req, res, next){
console.log('windSpeed post');
	var spinnerValue = req.body.windSpeedSliderValue;
	console.log('windSpeedSliderValue: '+req.body.windSpeedSliderValue);
	
	// res.render('windSpeed', {seeValue: spinnerValue });
	res.render('index', {title: 'Wind Lab', seeValue: spinnerValue });
		
	serialListener.write('r', spinnerValue + serialListener.delimiter );
   
})

router.put('/', function(req, res, next){
	var spinnerValue = req.body.value;
	res.seeValue = req.body.value;
	res.redirect('index');
})

router.get('/about', function(req, res){
	res.send('wind speed About page');
})

module.exports = router;

	