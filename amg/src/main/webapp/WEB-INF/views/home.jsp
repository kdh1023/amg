<%@ page contentType="text/html; charset=utf-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page session="false" %>
<html>
<head>
	<title>Home</title>
</head>
<link rel="stylesheet" type="text/css" href="/resources/css/common.css">
<script src="/resources/js/jquery/jquery-1.12.3.min.js"></script>
<script>
var hangeul1 = ['ㄱ', 'ㄴ', 'ㄷ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅅ', 'ㅇ', 'ㅈ'];
var hangeul2 = ['ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'];

function shuffle(array) {
	var currentIndex = array.length, temporaryValue, randomIndex;
	
	// While there remain elements to shuffle...
	while (0 !== currentIndex) {
	
	  // Pick a remaining element...
	  randomIndex = Math.floor(Math.random() * currentIndex);
	  currentIndex -= 1;
	
	  // And swap it with the current element.
	  temporaryValue = array[currentIndex];
	  array[currentIndex] = array[randomIndex];
	  array[randomIndex] = temporaryValue;
	}
	
	return array;
}

$(function(){
	// Used like so
	//arr = shuffle(hangeul1);
	//console.log(arr);
	
	(function($){
	    
        $.extend({
            
            APP : {                
                
                formatTimer : function(a) {
                    if (a < 10) {
                        a = '0' + a;
                    }                              
                    return a;
                },    
                
                startTimer : function(dir) {
                    
                    var a;
                    
                    // save type
                    $.APP.dir = dir;
                    
                    // get current date
                    $.APP.d1 = new Date();
                    
                    switch($.APP.state) {
                            
                        case 'pause' :
                            
                            // resume timer
                            // get current timestamp (for calculations) and
                            // substract time difference between pause and now
                            $.APP.t1 = $.APP.d1.getTime() - $.APP.td;                            
                            
                        break;
                            
                        default :
                            
                            // get current timestamp (for calculations)
                            $.APP.t1 = $.APP.d1.getTime(); 
                            
                            // if countdown add ms based on seconds in textfield
                            if ($.APP.dir === 'cd') {
                                $.APP.t1 += parseInt($('#cd_seconds').val())*1000;
                            }    
                        
                        break;
                            
                    }                                   
                    
                    // reset state
                    $.APP.state = 'alive';   
                    $('#' + $.APP.dir + '_status').html('Running');
                    
                    // start loop
                    $.APP.loopTimer();
                    
                },
                
                pauseTimer : function() {
                    
                    // save timestamp of pause
                    $.APP.dp = new Date();
                    $.APP.tp = $.APP.dp.getTime();
                    
                    // save elapsed time (until pause)
                    $.APP.td = $.APP.tp - $.APP.t1;
                    
                    // change button value
                    $('#' + $.APP.dir + '_start').val('Resume');
                    
                    // set state
                    $.APP.state = 'pause';
                    $('#' + $.APP.dir + '_status').html('Paused');
                    
                },
                
                stopTimer : function() {
                    
                    // change button value
                    $('#' + $.APP.dir + '_start').val('Restart');                    
                    
                    // set state
                    $.APP.state = 'stop';
                    $('#' + $.APP.dir + '_status').html('Stopped');
                    
                },
                
                resetTimer : function() {

                    // reset display
                    $('#' + $.APP.dir + '_ms,#' + $.APP.dir + '_s,#' + $.APP.dir + '_m,#' + $.APP.dir + '_h').html('00');                 
                    
                    // change button value
                    $('#' + $.APP.dir + '_start').val('Start');                    
                    
                    // set state
                    $.APP.state = 'reset';  
                    $('#' + $.APP.dir + '_status').html('Reset & Idle again');
                    
                },
                
                endTimer : function(callback) {
                   
                    // change button value
                    $('#' + $.APP.dir + '_start').val('Restart');
                    
                    // set state
                    $.APP.state = 'end';
                    
                    // invoke callback
                    if (typeof callback === 'function') {
                        callback();
                    }    
                    
                },    
                
                loopTimer : function() {
                    
                    var td;
                    var d2,t2;
                    
                    var ms = 0;
                    var s  = 0;
                    var m  = 0;
                    var h  = 0;
                    
                    if ($.APP.state === 'alive') {
                                
                        // get current date and convert it into 
                        // timestamp for calculations
                        d2 = new Date();
                        t2 = d2.getTime();   
                        
                        // calculate time difference between
                        // initial and current timestamp
                        if ($.APP.dir === 'sw') {
                            td = t2 - $.APP.t1;
                        // reversed if countdown
                        } else {
                            td = $.APP.t1 - t2;
                            if (td <= 0) {
                                // if time difference is 0 end countdown
                                $.APP.endTimer(function(){
                                    $.APP.resetTimer();
                                    $('#' + $.APP.dir + '_status').html('Ended & Reset');
                                });
                            }    
                        }    
                        
                        // calculate milliseconds
                        ms = td%1000;
                        if (ms < 1) {
                            ms = 0;
                        } else {    
                            // calculate seconds
                            s = (td-ms)/1000;
                            if (s < 1) {
                                s = 0;
                            } else {
                                // calculate minutes   
                                var m = (s-(s%60))/60;
                                if (m < 1) {
                                    m = 0;
                                } else {
                                    // calculate hours
                                    var h = (m-(m%60))/60;
                                    if (h < 1) {
                                        h = 0;
                                    }                             
                                }    
                            }
                        }
                      
                        // substract elapsed minutes & hours
                        ms = Math.round(ms/100);
                        s  = s-(m*60);
                        m  = m-(h*60);                                
                        
                        // update display
                        $('#' + $.APP.dir + '_ms').html($.APP.formatTimer(ms));
                        $('#' + $.APP.dir + '_s').html($.APP.formatTimer(s));
                        $('#' + $.APP.dir + '_m').html($.APP.formatTimer(m));
                        $('#' + $.APP.dir + '_h').html($.APP.formatTimer(h));
                        
                        // loop
                        $.APP.t = setTimeout($.APP.loopTimer,1);
                    
                    } else {
                    
                        // kill loop
                        clearTimeout($.APP.t);
                        return true;
                    
                    }  
                    
                },
                setHangeul : function() {
                	var arr = shuffle(hangeul1);
                	//console.log( arr + hangeul1.length);
                	for( var i = 1; i <= hangeul1.length; i++) {
                		$('#sec' + i).text(hangeul1[i-1]);
                	}
                }
                    
            }    
        
        });
          
        $('#sw_start').on('click', function() {
            $.APP.startTimer('sw');
            $.APP.setHangeul();
        });    

        $('#cd_start').on('click', function() {
            $.APP.startTimer('cd');
        });           
        
        $('#sw_stop,#cd_stop').on('click', function() {
            $.APP.stopTimer();
        });
        
        $('#sw_reset,#cd_reset').on('click', function() {
            $.APP.resetTimer();
        });  
        
        $('#sw_pause,#cd_pause').on('click', function() {
            $.APP.pauseTimer();
        });                
                
    })(jQuery);
});
</script>

<body>
<h1>
	Hello world!  
</h1>

<P>  The time on the server is ${serverTime}. </P>

<div>
    <h1>Stopwatch</h1>
    <span id="sw_h">00</span>:
    <span id="sw_m">00</span>:
    <span id="sw_s">00</span>:
    <span id="sw_ms">00</span>
    <br/>
    <br/>
    <input type="button" value="Start" id="sw_start" />
    <input type="button" value="Pause" id="sw_pause" />
    <input type="button" value="Stop"  id="sw_stop" />
    <input type="button" value="Reset" id="sw_reset" />
    <br/>
    <br/>
    <span id="sw_status">Idle</span>
</div>

<div>
    <h1>Countdown</h1>
    <span id="cd_h">00</span>:
    <span id="cd_m">00</span>:
    <span id="cd_s">00</span>:
    <span id="cd_ms">00</span>
    <br/>
    <br/>
    <input type="button" value="Start" id="cd_start" />
    <input type="button" value="Pause" id="cd_pause" />
    <input type="button" value="Stop"  id="cd_stop" />
    <input type="button" value="Reset" id="cd_reset" />
    <br/>
    <br/>
    <input type="text" value="15" id="cd_seconds" />
    secs
    <br/>
    <br/>
    <span id="cd_status">Idle</span>
</div>

<div>
	<table>
		<tr>
			<td id="sec1">ㄱ</td>
			<td id="sec2">ㄴ</td>
			<td id="sec3">ㄷ</td>
		</tr>
		<tr>
			<td id="sec4">ㄹ</td>
			<td id="sec5">ㅁ</td>
			<td id="sec6">ㅂ</td>
		</tr>
		<tr>
			<td id="sec7">ㅅ</td>
			<td id="sec8">ㅇ</td>
			<td id="sec9">ㅈ</td>
		</tr>
	</table>
</div>

</body>
</html>
