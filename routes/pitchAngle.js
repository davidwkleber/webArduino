//
// module for setting Pitch Angle of the wind turbine blades
//
var serialListener = require('../lib/serialListener');

var express = require('express');
var router = express.Router();

// middleware specific to this route, logs timestamps
router.use(function timeLog(req, res, next){
	console.log('pitchAngle Time: ', Date.now());
	next();
})

// define the home page route
router.get('/', function(req, res){
console.log('pitchAngle get');
 	res.redirect('/');
})

router.post('/', function(req, res, next){
console.log('pitchAngle post');
	var spinnerValue = req.body.pitchAngleSliderValue;
	res.render('index', {title: 'Wind Lab', PAseeValue: spinnerValue });
	serialListener.write('y', spinnerValue + serialListener.delimiter);

})

router.put('/', function(req, res, next){
	var spinnerValue = req.body.value;
	res.seeValue = req.body.value;
	res.redirect('/');
})

router.get('/about', function(req, res){
	res.send('About page');
})

module.exports = router;

	