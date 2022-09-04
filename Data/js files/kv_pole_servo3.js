/* ///////////    kV and pole measurement       /////////////

This script estimates the number of poles from the manufacturers' kV. 
If possible, you should still count the number of magnets as explained in the setup tab. 
DO NOT USE WITH A PROPELLER. The motor will spin at full speed.

Use: 
  1) Install the motor without a propeller
  2) Select the Electrical RPM Sensor as "Main Sensor" in the Setup tab.
  3) Clone the script, so it can be modified
  4) Change the "kV_manufacturer" to your motor's known KV value.
  5) Run the script

///////////// User defined variables //////////// */

var kV_manufacturer = 2260; // Input the manufacturer's kV here

///////////////// Beginning of the script //////////////////

// We assume 2 poles for now
rcb.sensors.setMotorPoles(2); 
rcb.sensors.setSafetyLimit("rpm",0,200000);

//Start ESC
rcb.console.print("Initializing ESC...");
rcb.output.set("servo3",1000);
rcb.wait(rampESC, 4);

//Ramp up to full throttle
function rampESC(){
    rcb.output.ramp("servo3", 1000, 2000, 15, settleFct);
}

//Settling time and recording
function settleFct(){
    rcb.console.print("Waiting to reach steady speed...");
    rcb.wait(function(){ // Wait for motor speed to stabilize
        rcb.console.print("Reading Data..."); 
        rcb.sensors.read(calcResult, 100);
    }, 4);

}

//Calculate number of poles
function calcResult(result) {
    var kV_2_poles = result.motorElectricalSpeed.workingValue/result.voltage.workingValue;
    // The kV measured is a multiple of the manufacturers' kV.
    var pole_estimate = math.round(kV_2_poles/kV_manufacturer)*2;
    var kV_measured = kV_2_poles/pole_estimate*2;
    rcb.console.print("The estimated number of poles is: "+ pole_estimate);
    rcb.console.print("With "+ pole_estimate + " poles, the real motor kV is: " + Math.round(kV_measured));  
    rcb.endScript();
}