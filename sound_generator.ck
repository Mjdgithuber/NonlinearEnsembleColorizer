/*

  Client audio script - auditions the correct sample when client selects from bottom selection bar

*/

// MIDI note constants
60 => int c;     72 => int C;
61 => int cs;    73 => int Cs;
62 => int d;     74 => int D;
63 => int ds;    75 => int Ds;
64 => int e;     76 => int E;
65 => int f;     77 => int F;
66 => int fs;    78 => int Fs;
67 => int g;     79 => int G;
68 => int gs;    80 => int Gs;
69 => int a;     81 => int A;
70 => int as;    82 => int As;
71 => int b;     83 => int B;

// https://chuck.cs.princeton.edu/release/files/chuck_manual.pdf
// ^^^ StkInstrument for timbre!!! ^^^

[ 0, 2, 5, 7, 9 ] @=> int pentatonic_notes[];
[ [0,0,0,2], [4,4,5,7], [7,9,9,11] ] @=> int chords[][];

6664 => int inPort;
-1 => int id; 

if( me.args() ) me.arg(0) => Std.atoi => id;
if( me.args() ) me.arg(1) => Std.atoi => inPort;

OscIn oin;
OscMsg msg;
inPort => oin.port;
oin.addAddress( "/gridocolor, isiiii" );

// ROBS PANNING CODE
// place around a stereo -1 to 1 field
//(( (id * (1.0/cellCount)) * 2.0) - 1.0) * -1.0 => pan;
//pan => p.pan;


// SndBuf s[12];
// 0 => int sCounter;

// JCRev r => Gain g => dac;

//SinOsc s => Gain g => dac;

/*
for( int i; i < s.cap(); i++ ) { 
    s[i] => r; 
    0 => s[i].gain; 
}

.01 => r.mix;

16.0 => float userCount;
*/

// string sampleName[9];
// int sampleset;

/* returns a code based on the largest rgb value(s) as follows:
0: all are tied
1: red, 2:green, 3: blue
4: r-g tie, 5: g-b tie, 6: r-b tie
*/
fun int getLargest( int r, int g, int b ) {
    if( r>g ) {
        if( r>b ) return 1;
        else if( r==b ) return 6;
    }
    if( g>b ) {
        if( g>r ) return 2;
        else if( g==r ) return 4;
    }
    if( b>r ) {
        if( b>g ) return 3;
        else if( b==g ) return 5;
    }
    else {
        return 0;
    }
}
    
// call this if id has changed when OSC message is received
fun string setup( int R, int G, int B )
{
    /*
    RED (Strings) = (50-255, 0-250, 0-250) (255, 0, 0)
    ORANGE (Brass) = (160-255, 85-245, 0-238) (255, 150, 0) Largest: red
    YELLOW (Percussion) = (181-255, 166-255, 66-240) (255, 255, 0) Largest: red/green
    GREEN (Saxophone) = (0-178, 107-255, 0-175) (0, 255, 0)
    BLUE (Woodwinds) = (0-248, 0-248, 102-255) (0, 0, 255)
    PURPLE (Guitar) = (93-209, 0-159, 84-232) (150, 0, 255) Largest: blue
    OTHER (Sine osc)
    */

    /* get the largest rgb value; if red, then color = RED, ORANGE, or YELLOW;
       if green, color = YELLOW OR GREEN; if blue, color = BLUE OR PURPLE */

    "" => string color;
    getLargest(R,G,B) => int code;
    // red is largest number in rgb
    if( code == 1 ) {
        R-G => float gdiff;
        R-B => float bdiff;
        /* ratio is how different red and green values are: the larger the ratio, the more red it is
           a small weight is also given to the blue value, as it can change the color from yellow to orange */
        (gdiff + B*0.05 + R*.1)/ R => float ratio;
        // Math.pow((R-60)/18, 1.8)+20 => float greenLimit;
        bdiff/R => float bratio;

        if( R<70 || (bdiff/R)<0.18 || bratio<0.4 ) {
            "OTHER" => color;
        }

        // hopefully works
        else if( ratio > 0.65 ) { // (255,90,0)
            "RED" => color;
        }
        else if( ratio > 0.21 ) {
            "ORANGE" => color;
        }
        else {
            "YELLOW" => color;
        }
        /*
        else if( G<greenLimit ) { // (255,90), (150,40), (70,20)
            "RED" => color;
        }
        else if( ratio > 0.21 ) { // (255,200), (150,110), (70,62)
            "ORANGE" => color;
        }
        else {
            "YELLOW" => color;
        }
        */
    }
    else if( code == 2 ) {
        G-R => float rdiff;
        G-B => float bdiff;
        (rdiff + B*0.1)/ G => float ratio;

        if( G<40 || (rdiff<10 && bdiff<10) ) {
            "OTHER" => color;
        }
        // hopefully works
        else if( ratio > 0.15 ) {
            "GREEN" => color;
        }
        else {
            "YELLOW" => color;
        }
    }
    else if( code == 3 ) {
        B-R => float rdiff;
        B-G => float gdiff;
        (rdiff + G*0.125)/ B => float ratio;

        if( B<60 || (rdiff<15 && gdiff<15) ) {
            "OTHER" => color;
        }
        // hopefully works
        else if( ratio > 0.61 || G>R ) {
            "BLUE" => color;
        }
        else {
            "PURPLE" => color;
        }
    }
    //red-green tie
    else if( code == 4 ) {
        if( R<150 ) {
            "GREEN" => color;
        }
        else {
            "YELLOW" => color;
        }
    }
    //green-blue tie
    else if( code == 5 ) {
        "BLUE" => color;
    }
    //blue-red tie
    else if( code == 6 ) {
        "PURPLE" => color;
    }

    if( "" == color ) {
        "OTHER" => color;
    }
    return color;
}

0 => int flag;

int currentClientId, currentValue;

string clientName;
int currentId, currentIndex, currentRed, currentGreen, currentBlue;

while(true)
{
    oin => now;
       
    if(flag==0) {
        <<< "[grid] OSC input received..." >>>; 
        1 => flag;
    }
    
    // get message
    
    // grab the next message from the queue. 
    while( oin.recv(msg) )
    {             
        // /oscMultiGrid <port> <client-id> <button-pressed> <RGBvalues>
        msg.getInt(0) => currentId;
        msg.getString(1) => clientName;
        msg.getInt(2) => currentIndex;
        msg.getInt(3) => currentRed;
        msg.getInt(4) => currentGreen;
        msg.getInt(5) => currentBlue;

        <<< currentId, clientName, currentIndex, currentRed, currentGreen, currentBlue >>>;
        
        // reset sample set if client id has changed - will run on first selection too with default -1 val
        setup( currentRed, currentGreen, currentBlue ) => string colr;
        
        //<<< "C = " + c >>>;
        
        12*(currentIndex/pentatonic_notes.cap()) + 48 + pentatonic_notes[ currentIndex % pentatonic_notes.cap() ] => int p_value;
        chords[currentIndex/chords[0].cap()][currentIndex%chords[0].cap()] => int value;

        if( colr == "RED" ){
            spork ~ playStrings(c+value);
        }
        else if( colr == "ORANGE" ) {
           spork ~ playTrumpet(g+value);
        }
        else if( colr == "YELLOW" ) {
           spork ~ playFlute(p_value);
        }
        else if( colr == "GREEN" ) {
            spork ~ playSax(as+value);
        }
        else if( colr == "BLUE" ) {
            spork ~ playClarinet(f+value);
        }
        else if( colr == "PURPLE" ) {
            spork ~ playGuitar(d+value);
        }
        else {
            spork ~ play(p_value);
        }
    }
}

fun void play( int value )
{
    500::ms => dur currentDuration;
    
    SinOsc s => Envelope e => Gain g => dac;
    0.8 => g.gain;
    
    48 => int currentRoot;
    Std.mtof(value) => float currentFreq;
    currentFreq => s.freq;
    
    currentDuration => e.duration;
    
    e.keyOn();
    currentDuration => now;
    e.keyOff();
    currentDuration => now;
}

fun void playFlute( int value ) {
    500::ms => dur currentDuration;

    Flute flute => Envelope e => PoleZero f => JCRev r => dac;
    0.75 => r.gain; //volume
    0.1 => r.mix; //reverb
    .99 => f.blockZero; // I am so confused oh my god

    .7 => flute.jetDelay;
    .5 => flute.jetReflection;
    .4 => flute.endReflection;
    .7 => flute.pressure;
    currentDuration => e.duration;

    Std.mtof( value ) => flute.freq;
    .9 => flute.noteOn;
    e.keyOn();
    currentDuration => now;
    e.keyOff();
    currentDuration => now;
}

fun void playClarinet( int value ) {
    500::ms => dur currentDuration;

    Clarinet clar => Envelope e => JCRev r => dac;
    .75 => r.gain;
    .1 => r.mix;
    currentDuration => e.duration;

    .6 => clar.startBlowing;
    Std.mtof( value ) => clar.freq;
    e.keyOn();
    currentDuration => now;
    e.keyOff();
    currentDuration => now;
    1 => clar.stopBlowing;
    0.2::second => now;
}

fun void playGuitar( int value ) {
    500::ms => dur currentDuration;

    StifKarp guitar => Envelope e => dac;
    currentDuration => e.duration;

    // gives different frequencies, figure out how to deal with this properly later with value
    .01*value => guitar.stretch;
    1 => guitar.noteOn;

    e.keyOn();
    currentDuration => now;
    e.keyOff();
    currentDuration => now;
}

fun void playStrings( int value ) {
    500 => float myDuration;
    myDuration::ms => dur currentDuration;

    Bowed violin => Envelope e => dac;
    10 => violin.vibratoFreq;    

    currentRed/254.0 => violin.bowPressure;
    currentRed/(254.0*50.0) => violin.vibratoGain;
    //Math.random2f( 0, 1 ) => bow.bowPressure;
    //Math.random2f( 0, 1 ) => bow.bowPosition;
    //Math.random2f( 0, 12 ) => bow.vibratoFreq;
    //Math.random2f( 0, 1 ) => bow.vibratoGain;
    //Math.random2f( 0, 1 ) => bow.volume;
    <<< currentRed >>>;

    (myDuration/2.0)::ms => e.duration;

    Std.mtof( value ) => violin.freq;
    .8 => violin.noteOn;

    e.keyOn();
    (myDuration/2.0)::ms => now;
    e.keyOff();
    (myDuration/2.0)::ms => now;
}

fun void playTrumpet( int value ) {
    500::ms => dur currentDuration;

    Brass trump => Envelope e => NRev r => dac;
    0.75 => r.gain;
    0.1 => r.mix;
    0.6 => trump.volume;
    currentDuration => e.duration;

    // value here may need to be changed to a flat 0.4 (velocity)
    0.8 => trump.startBlowing;
    Std.mtof(value) => trump.freq;
    e.keyOn();
    currentDuration => now;
    e.keyOff();
    1 => trump.stopBlowing;
    0.05::second => now;
}

fun void playSax( int value ) {
    500::ms => dur currentDuration;

    Saxofony sax => Envelope e => JCRev r => dac;
    .5 => r.gain;
    .05 => r.mix;
    currentDuration => e.duration;

    12 => sax.vibratoFreq;
    Std.mtof( value ) => sax.freq;
    .7 => sax.noteOn;
    e.keyOn();
    currentDuration => now;
    e.keyOff();
    currentDuration => now;
}

1::day => now;