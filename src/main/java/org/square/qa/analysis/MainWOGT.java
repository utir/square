package org.square.qa.analysis;

import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;
import org.square.qa.algorithms.BayesGeneralized;
import org.square.qa.algorithms.BinaryMapEstRY;
import org.square.qa.algorithms.MajorityVoteGeneralized;
import org.square.qa.algorithms.ZenCrowdEM;
import org.square.qa.utilities.constructs.*;
import org.square.qa.utilities.constructs.GeneralUtils.nFoldSet;
import org.square.qa.utilities.fileParsers.FileParserJStrings;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.*;

final class MainWOGT {
	private String responsesFile;
	private String categoriesFile;
	private String categoriesPriorFile;
	private estMethod chosenMethod;
	private estType estimationType;
	private int numIterations;
	private static Logger log = Logger.getLogger(Main.class);
	private File outDir = null;
	private File loadDir = null;
	
	private MainWOGT() {
		responsesFile = null;
		categoriesFile = null;
		categoriesPriorFile = null;
		numIterations = 50;
		estimationType = estType.unsupervised;}
	
	public enum estMethod{
		Raykar,Bayes,Zen,Majority,All;}
	
	public enum estType{
		unsupervised,semiSupervised,supervised;}
	
	/**
	 * Loads environment variables 
	 * @param args is a String[] of command line arguments 
	 */
	public void setupEnvironment(String[] args){
		  int argIndex = 0;
		  boolean minReq = false;
		  
		  while (argIndex < args.length && args[argIndex].startsWith("--")){
			  if(args[argIndex].equalsIgnoreCase("--responses")){
				  if (!(minReq == false)) log.error("Load path defined!");
				  assert minReq == false:"Load path defined!";				
				  responsesFile = args[++argIndex];
				  minReq = true;
				  log.info("Worker responses file specified: "+responsesFile);}
			  
			  if(args[argIndex].equalsIgnoreCase("--method")){
				  argIndex++;
				  if(args[argIndex].equalsIgnoreCase("Raykar")){
					  chosenMethod = estMethod.Raykar;
				  } else if (args[argIndex].equalsIgnoreCase("Bayes")) {
					  chosenMethod = estMethod.Bayes;
				  } else if (args[argIndex].equalsIgnoreCase("Zen")) {
					  chosenMethod = estMethod.Zen;
				  } else if (args[argIndex].equalsIgnoreCase("Majority")){
					  chosenMethod = estMethod.Majority;
				  } else if (args[argIndex].equalsIgnoreCase("All")){
					  chosenMethod = estMethod.All;
				  } else {
					  chosenMethod = estMethod.Majority;}
				  log.info("Chosen estimation method: "+chosenMethod);}
			  
			  log.info("Chosen estimation type: "+estimationType);
			  
		  	  if(args[argIndex].equalsIgnoreCase("--category")){
				  categoriesFile = args[++argIndex]; 
				  log.info("Categories file specified: "+categoriesFile);}
			  
		  	  if(args[argIndex].equalsIgnoreCase("--categoryPrior")){
				  categoriesPriorFile = args[++argIndex]; 
				  log.info("Categories file specified: "+categoriesPriorFile);}
		  	  
			  if(args[argIndex].equalsIgnoreCase("--numIterations")){
				  numIterations = Integer.parseInt(args[++argIndex]);
				  log.info("Number of iterations specified: "+numIterations);}
			  
			  if(args[argIndex].equalsIgnoreCase("--saveDir")){
				  outDir = new File(args[++argIndex]);
				  log.info("Saving files in: " + outDir);}
			  
			  if(args[argIndex].equalsIgnoreCase("--loadDir")){
				  if (!(minReq == false)) log.error("Worker Responses defined! Loading will overwrite");
				  assert minReq == false:"Worker Responses defined! Loading will overwrite";
				  minReq = true;
				  loadDir = new File(args[++argIndex]);
				  log.info("Loading files from: " + loadDir);}
			  argIndex++;}
		  
		  assert minReq:"\nResponses File Not Defined -- see usage";}
	
	/**
	 * Loads data from input files 
	 * @throws IOException
	 */
	private void initializeFromFiles() throws IOException{
		assert responsesFile!=null:"Environment not initialized";		
		FileParserJStrings fParser = new FileParserJStrings();
		log.info("Attempting to parse worker responses.");
		fParser.setFileName(responsesFile);
		
		Map<String,workersDataStruct<String,String> > workersMap = fParser.parseWorkerLabels();
		GeneralUtils.nFoldSet.workersMap = workersMap;
		
		Map<String,Double> categMapPriors=null;
		if(categoriesPriorFile!=null){
			fParser.setFileName(categoriesPriorFile);
			categMapPriors = fParser.parseCategoriesWPrior();
			if(log.isDebugEnabled())
				log.debug("Contents of Category and Prior Map:\n"+categMapPriors);}
		
		TreeSet<String> responseCategories=null;
		if(categoriesFile!=null){
			responseCategories = new TreeSet<String>();
			fParser.setFileName(categoriesFile);
			responseCategories.addAll(fParser.parseCategories());
			if(log.isDebugEnabled())
				log.debug("Contents of sorted response categories set:\n"+responseCategories);}
		
		if(categoriesPriorFile!=null && responseCategories==null){
			responseCategories = new TreeSet<String>();
			for(String category:categMapPriors.keySet()){
				responseCategories.add(category);}
			if(log.isDebugEnabled())
				log.debug("Contents of sorted response categories set:\n"+responseCategories);}
		
		GeneralUtils.nFoldSet.responseCategories = responseCategories;
		GeneralUtils.fillNFoldClass(responseCategories);}

	private void loadFromSavedFiles() throws IOException{
			FileParserJStrings fParser = new FileParserJStrings();
			
			fParser.setFileName(loadDir.getAbsolutePath() + "/responses_eval.txt");
			fParser.coloumnSwitch = true;
			GeneralUtils.nFoldSet.workersMap = fParser.parseWorkerLabels();
			fParser.coloumnSwitch = false;
			
			File file = new File(loadDir.getAbsolutePath() + "/model");
			File modelFiles[] = file.listFiles();
			nFoldSet.responseCategories = new TreeSet<String>();
			for(File modelFile:modelFiles){
				String modelFileName = modelFile.getName();
				if(modelFileName.equalsIgnoreCase("map_category_integer.txt")){
					fParser.setFileName(modelFile.getAbsolutePath());
					Map<String,String> categToIntMap = fParser.parseGoldStandard();
					for(String oldName:categToIntMap.keySet()){
						nFoldSet.responseCategories.add(categToIntMap.get(oldName));}}}}
	
	/**
	 * Performs n-fold evaluation
	 * @throws IOException
	 */
	public void flow() throws IOException{
		GeneralUtilsParameterized<String, String, String> paramUtils = new GeneralUtilsParameterized<String, String, String>();
		if(loadDir!=null)
			loadFromSavedFiles();
				
		if(loadDir==null&&outDir!=null){
			initializeFromFiles();
			if(!outDir.isDirectory())
				outDir.mkdirs();
			paramUtils.printNumberedResponses(GeneralUtils.nFoldSet.workersMap,new File(outDir.getAbsolutePath()+"/responses_eval.txt"));
			File paramDir = new File(outDir.getAbsolutePath() +"/model");
			if(!paramDir.isDirectory())
				paramDir.mkdir();
			paramUtils.printMapFileWI(GeneralUtils.nFoldSet.workerToInt, new File(paramDir.getAbsolutePath()+"/map_worker_integer.txt"));
			paramUtils.printMapFileQI(GeneralUtils.nFoldSet.questionToInt, new File(paramDir.getAbsolutePath()+"/map_question_integer.txt"));
			paramUtils.printMapFileRI(GeneralUtils.nFoldSet.categToInt, new File(paramDir.getAbsolutePath()+"/map_category_integer.txt"));
			GeneralUtils.printStatistics(GeneralUtils.nFoldSet.workersMap,new File(outDir.getAbsolutePath()+"/statistics/train"));}
		
		Models<String,String,String> models = new Models<String, String, String>();
		Map<String,String> printStrings = new HashMap<String, String>();
		Map<String,String> printRLabelStrings = new HashMap<String, String>();
		GeneralUtils.printStatistics(GeneralUtils.nFoldSet.workersMap);
		List<Pair<estMethod,Results<String,String> > > resultObjects = null;
		models.setWorkersMap(GeneralUtils.nFoldSet.workersMap);
		models.setResponseCategories(GeneralUtils.nFoldSet.responseCategories);
		if(chosenMethod.equals(estMethod.Zen)||chosenMethod.equals(estMethod.All)){
			models.getZenModel().useClassPrior = true;
			models.getZenModel().useWorkerPrior = true;}
		if(chosenMethod.equals(estMethod.Raykar)||chosenMethod.equals(estMethod.All)){
			models.getRaykarModel().useClassPrior = true;
			models.getRaykarModel().useWorkerPrior = true;}
		resultObjects = estimateLabels(models,false);
		for(Pair<estMethod,Results<String,String> >  result:resultObjects){
			result.getSecond().computeComparableResuts();
			result.getSecond().computeComparableResultVector();
			log.info(result.getFirst() + ": " + "Ground Truth Not Available"+"\n");	
			if(outDir != null){
				if(printRLabelStrings.containsKey(result.getFirst().toString())){
					printRLabelStrings.put(result.getFirst().toString(),printRLabelStrings.get(result.getFirst().toString())+result.getSecond().printComparableResults(false));
				} else {
					printRLabelStrings.put(result.getFirst().toString(),result.getSecond().printComparableResults(true));}}
			
			if(log.isDebugEnabled()){
				log.debug(result.getSecond().getComparableResultVector());}}

		if(outDir == null)
			outDir = new File("./results");
		if(outDir!=null){
			File resultsDir = new File(outDir.getAbsolutePath()+"/results/nFold");
			File aggregatedLabelsDir = new File(outDir.getAbsolutePath()+"/results/nFold/aggregated");
			if(!resultsDir.exists()){
				resultsDir.mkdirs();}
			if(!aggregatedLabelsDir.exists()){
				aggregatedLabelsDir.mkdirs();}
			for(String key:printRLabelStrings.keySet()){
				String name = "supervised";
				
				if(key.equals("Majority"))
					name = "unsupervised";
				
				if(key.equals("Zen")){
					if(estimationType.toString().equals("unsupervised"))
						name = "unsupervised";
					if(estimationType.toString().equals("semiSupervised"))
						name = "semisupervised";
					if(estimationType.toString().equals("supervised"))
						name = "supervised";}
				
				if(key.equals("Raykar")){
					if(estimationType.toString().equals("unsupervised"))
						name = "unsupervised";
					if(estimationType.toString().equals("semiSupervised"))
						name = "semisupervised";
					if(estimationType.toString().equals("supervised"))
						name = "supervised";}
				
				if(!printStrings.isEmpty()){
					PrintWriter out = new PrintWriter(new File(resultsDir.getAbsolutePath() + "/"+key+"_"+name+"_results.txt"));
					out.print(printStrings.get(key));
					out.close();}
				PrintWriter out = new PrintWriter(new File(aggregatedLabelsDir.getAbsolutePath() + "/"+key+"_"+name+"_aggregated.txt"));
				out.print(printRLabelStrings.get(key));
				out.close();}}}
	
	/**
	 * 
	 * @param models
	 * @param runTest
	 * @return
	 */
	public List<Pair<estMethod,Results<String,String> > > estimateLabels(Models<String,String,String> models, boolean runTest){
		List<Pair<estMethod,Results<String,String> > > resultObjects = new ArrayList<Pair<estMethod,Results<String,String> > >();
		boolean all = false;
		switch(chosenMethod){
		case All:
			all = true;
		case Majority:
			MajorityVoteGeneralized<String, String, String> majority = new MajorityVoteGeneralized<String, String, String>(models.getMajorityModel());
			majority.computeLabelEstimates();
			resultObjects.add(new Pair<estMethod,Results<String,String> >(estMethod.Majority, new Results<String,String>(models.getMajorityModel().getCombinedEstLabels(),models.getMajorityModel().getResponseCategories())));
			if(!all)break;
		case Bayes:
			if(models.getBayesModel().hasGoldStandard()){
				models.getBayesModel().setLapAlpha(1.0d);
				models.getBayesModel().setLapBeta((double)models.getBayesModel().getResponseCategories().size());
				models.getBayesModel().computeDefaultNewWorkerConfusion();
				BayesGeneralized<String, String, String> bayes = new BayesGeneralized<String, String, String>(models.getBayesModel(),false);
				bayes.computeLabelEstimates();
				resultObjects.add(new Pair<estMethod,Results<String,String> >(estMethod.Bayes, new Results<String,String>(models.getBayesModel().getCombinedEstLabels(),models.getBayesModel().getResponseCategories())));}
			if(!all)break;			
		case Zen:
			ZenCrowdEM<String, String, String> zen = new ZenCrowdEM<String, String, String>(models.getZenModel());
			zen.computeLabelEstimates();
			resultObjects.add(new Pair<estMethod,Results<String,String> >(estMethod.Zen, new Results<String,String>(models.getZenModel().getCombinedEstLabels(),models.getZenModel().getResponseCategories())));
			if(!all)break;
		case Raykar:
			if(models.getRaykarModel().getResponseCategories().size()>2)break;
			models.getRaykarModel().setPositiveClass(models.getRaykarModel().getResponseCategories().iterator().next());
			BinaryMapEstRY<String, String, String> raykar = new BinaryMapEstRY<String, String, String>(models.getRaykarModel());
			raykar.computeLabelEstimates();
			resultObjects.add(new Pair<estMethod,Results<String,String> >(estMethod.Raykar, new Results<String,String>(models.getRaykarModel().getCombinedEstLabels(),models.getRaykarModel().getResponseCategories())));
			if(!all)break;}
		return resultObjects;}
	
	/**
	 * Main function
	 * @param args is a String[] which holds command line args
	 * @throws IOException
	 */
	public static void main(String... args) throws IOException {
		
		PropertyConfigurator.configure("/Users/aashish/dev/java/crwdQA/crowdQA_Algorithms/src/main/resources/log4j.properties");
		if (!(args.length != 0)) log.error("Usage: org.square.qa.analysis.Main --responses [responsesFile] --category [categoriesFile] --categoryPrior [categoryPriorFile] --numIteration [numIterations] --method <Majority|Bayes|Raykar|Zen|All> --nfold [n]\nRequired Parameters: --responses --category\nOptional usage(specify file with args): --file [file]");
		assert args.length != 0 : "Usage: org.square.qa.analysis.Main --responses [responsesFile] --category [categoriesFile] --categoryPrior [categoryPriorFile] --numIteration [numIterations] --method <Majority|Bayes|Raykar|Zen|All> --nfold [n]\nRequired Parameters: --responses --category\nOptional usage(specify file with args): --file [file]";
		
		boolean usingFile = false;
		
		MainWOGT obj;
		
		if(args[0].equalsIgnoreCase("--file")){
			usingFile = true;
			File argsFile = new File(args[1]);
			Scanner lineScan = new Scanner(argsFile);
			while(lineScan.hasNextLine()){
				String tempArgs = lineScan.nextLine();
				if(tempArgs.equals(""))
					continue;
				String[] currentArgs = tempArgs.split(" ");
				obj = new MainWOGT();
				obj.setupEnvironment(currentArgs);
				obj.flow();}}
		
		if(!usingFile){
			obj = new MainWOGT();
			obj.setupEnvironment(args);
			obj.flow();}}}

