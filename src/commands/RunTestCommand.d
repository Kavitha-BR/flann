module commands.RunTestCommand;

import tango.text.Util : split;
import tango.util.Convert;
import tango.time.WallClock;

import commands.GenericCommand;
import commands.IndexCommand;
import nn.Testing;
import dataset.Features;
import algo.NNIndex;
import output.Console;
import output.Report;
import util.Logger;
import util.Utils;
import util.Profiler;


static this() {
 	register_command!(RunTestCommand);
}

class RunTestCommand : IndexCommand
{
	public static string NAME = "run_test";
	
	string testFile;
	string matchFile;
	uint nn;
	string checkList;
	int[] checks;
	char[] precisionList;
	uint skipMatches;
	bool altEstimator = false;
	char[] approxMatch;
	float maxTime;

	this(string name) 
	{
		super(name);
		register(testFile,"t","test-file", "","Name of file with test dataset.");
		register(matchFile,"m","match-file", "","File containing ground-truth matches.");
		register(nn,"n","nn", 1,"Number of nearest neighbors to search for.");
		register(checkList,"c","checks", "32","Number of times to restart search (in best-bin-first manner).");
		register(precisionList,"P","precision", "","A coma-separated list with the desired precisions to be tested.");
		register(altEstimator,"A","alternative-estimator", null,"Use alternative precision estimator.");
		register(skipMatches,"K","skip-matches", 0u,"Skip the first NUM matches at test phase.");
		register(approxMatch,"X","approx-match", "","File to save approx matches to.");
		register(maxTime,"T","max-time", 0 ,"Max time for one search.");
 			
 		description = super.description~" Test the index against the test dataset (ground truth given in the match file).";
	}
	
	private void executeWithType(T)() 
	{
		
/+		if (params["checks"]!=null) {
			checkList = params["checks"].get!(string);
		}+/
		
		checks = convert!(typeof(checks),string[])(split(checkList,","));

		Features!(float) testData;
/+		if ((testFile == "") && (inputData !is null)) {
			testData = inputData;
		}
		else +/
		if (testFile != "") {
			showOperation("Reading test data from "~testFile,{
				testData = new Features!(float)();
				testData.readFromFile(testFile);
			});
		}
		if (testData is null) {
			throw new Exception("No test data given.");
		}
		
		if (matchFile != "") {
			testData.readMatches(matchFile);
		}
		
		if (testData.match is null) {
			throw new Exception("There are no correct matches to compare to, aborting test phase.");
		}
		
		report("test_count", testData.count);
		report("nn", nn);
		
		auto d = WallClock.toDate();
		char[] dateTime = sprint("{}-{}-{} {:D2}:{:D2}:{:D2}",d.date.year,d.date.month,d.date.day,d.time.hours,d.time.minutes,d.time.seconds).dup;
		report("date",dateTime);

		if (precisionList != "") {
			char[][] precisionStrList = split(precisionList,",");
			float[] precisions = to!(float[])(precisionStrList);
			
			testNNIndexPrecisions!(T,true,true)(index,inputData!(T),testData, precisions, nn, skipMatches, maxTime );
 			
		}
		else {
			foreach (c;checks) {
				testNNIndex!(T,true,true)(index,inputData!(T),testData, c, nn, skipMatches);
			}
		}

	}
	

	void execute() 
	{
		super.execute();

		if (byteFeatures) {
			executeWithType!(ubyte)();
		} else {
			executeWithType!(float)();
		}
	}
	
}